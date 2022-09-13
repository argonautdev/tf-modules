include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  map_users = local.account_vars.locals.map_users
  map_accounts = local.account_vars.locals.map_accounts

  env = local.environment_vars.locals.environment

  region = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
# terraform {
#   source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql?ref=v0.4.0"
# }

terraform {

  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/rds?ref={{.RefVersion}}"
}

dependency "vpc" {
  config_path = "../vpc"
   mock_outputs = {
    vpc_id = "temporary-dummy-id",
    public_subnets = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"],
    private_subnets = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"],
    database_subnets = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"],
    vpc_cidr_block = "10.0.0.0/8"
    default_security_group_id = "default"
  }
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name"        = "{{ .Spec.name }}"
    "argonaut.dev/type"        = "RDS"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/rds-engine"  = "{{ .Spec.engine }}"
    "argonaut.dev/env/${local.env}" = "true"
  }
  aws_region = "${local.region}"

  visibility = "{{ .Spec.visibility }}"

  identifier     = "{{ .Spec.identifier }}"
  name           = "{{ .Spec.name }}"
  multi_az = "{{.Spec.multi_az }}"

  {{if eq .Spec.engine "postgres"}}
  // all values correspond to postgres
  engine         = "{{ .Spec.engine }}"
  // enhanced monitoring
  monitoring_interval = 60
  create_monitoring_role = true
  // If true is specified, no DBSnapshot is created.
  skip_final_snapshot = true
  delete_automated_backups = true
  monitoring_role_name = "{{ .Spec.identifier }}-monitoring-role"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  {{if .Spec.engine_version}}engine_version = "{{ .Spec.engine_version }}"{{end}}
  {{if .Spec.family}}family       = "{{ .Spec.family }}"{{end}}
  {{if .Spec.major_engine_version}}major_engine_version       = "{{ .Spec.major_engine_version}}"{{end}}
  {{end}}
  
  
  {{if eq .Spec.engine "mysql"}}
  // all values correspond to mysql
  engine         = "{{ .Spec.engine }}"
  // enhanced monitoring
  monitoring_interval = 60
  create_monitoring_role = true
  // If true is specified, no DBSnapshot is created.
  skip_final_snapshot = true
  delete_automated_backups = true
  monitoring_role_name = "{{ .Spec.identifier }}-monitoring-role"
  enabled_cloudwatch_logs_exports = ["audit", "general", "error", "slowquery"]
  // To enable enhance monitoring and write logs to cloudwatch should create custom parameter group and option group
  parameters = [
    {
      "name": "slow_query_log",
      "value": "1"
    },
    {
      "name": "general_log",
      "value": "1"
    },
    {
      "name": "log_output",
      "value": "FILE"
    }
  ]
  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
    }
  ]
  {{if .Spec.engine_version}}engine_version = "{{ .Spec.engine_version }}"{{else}}engine_version = "8.0.26"{{end}}
  {{if .Spec.family}}family       = "{{ .Spec.family }}"{{else}}family       = "mysql8.0"{{end}}
  {{if .Spec.major_engine_version}}major_engine_version       = "{{ .Spec.major_engine_version }}"{{else}}major_engine_version       = "8.0"{{end}}
  {{if or (eq .Spec.instance_class "db.t2.micro") (eq .Spec.instance_class "db.t2.small") (eq .Spec.instance_class "db.t3.micro") (eq .Spec.instance_class "db.t3.small")}}performance_insights_enabled=false{{else}}performance_insights_enabled=true{{end}}
  {{end}}
  
  {{if eq .Spec.engine "mariadb"}}
  // all values correspond to mariadb
  engine = "{{ .Spec.engine }}"
  // enhanced monitoring
  monitoring_interval = 60
  create_monitoring_role = true
  // If true is specified, no DBSnapshot is created.
  skip_final_snapshot = true
  delete_automated_backups = true
  monitoring_role_name = "{{ .Spec.identifier }}-monitoring-role"
  enabled_cloudwatch_logs_exports = ["audit", "general", "error", "slowquery"]
  // To enable enhance monitoring and write logs to cloudwatch should create custom parameter group and option group
  parameters = [
    {
      "name": "slow_query_log",
      "value": "1"
    },
    {
      "name": "general_log",
      "value": "1"
    },
    {
      "name": "log_output",
      "value": "FILE"
    }
  ]
  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
    }
  ]
  {{if eq .Spec.engine_version}}engine_version = "{{ .Spec.engine_version}}"{{else}}engine_version = "10.3.35"{{end}}
  {{if eq .Spec.family}}family = "{{.Spec.family}}"{{else}}family = "mariadb10.3"{{end}}
  {{if .Spec.major_engine_version}}major_engine_version       = "{{ .Spec.major_engine_version}}"{{else}}major_engine_version="10.3"{{end}}
  {{if or (eq .Spec.instance_class "db.t2.micro") (eq .Spec.instance_class "db.t2.small") (eq .Spec.instance_class "db.t3.micro") (eq .Spec.instance_class "db.t3.small")}}performance_insights_enabled=false{{else}}performance_insights_enabled=true{{end}}
  {{end}}
  storage        = {{ .Spec.storage }}
  {{if eq .Spec.max_allocated_storage}}max_allocated_storage = "{{.Spec.max_allocated_storage}}"{{else}}max_allocated_storage = 1000{{end}}  
  instance_class = "{{ .Spec.instance_class }}"
  username       = "{{ .Spec.username }}"
  password       = "{{ .Spec.password }}"
  vpc = {
    name    = "${local.env}"
    vpc_id      = dependency.vpc.outputs.vpc_id
    vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
    public_subnets = dependency.vpc.outputs.public_subnets
    private_subnets = dependency.vpc.outputs.private_subnets
    database_subnets = dependency.vpc.outputs.database_subnets
    default_security_group_id = dependency.vpc.outputs.default_security_group_id
  }
}