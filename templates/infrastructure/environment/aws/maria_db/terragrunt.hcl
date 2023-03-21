include {
  path = find_in_parent_folders()
}

locals {
  region = local.region_vars.locals.aws_region
}

terraform {

  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/maria_db?ref={{.RefVersion}}"
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

  instance_name     = "{{ .Spec.instance_name }}"
  database_name           = "{{ .Spec.database_name }}"
  multi_az = "{{.Spec.multi_az }}"
  backup_retention_period = "{{.Spec.backup_retention_period }}"

  {{if eq .Spec.engine_version}}engine_version = "{{ .Spec.engine_version}}"{{else}}engine_version = "10.3.35"{{end}}
  {{if eq .Spec.db_instance_family}}family = "{{.Spec.db_instance_family}}"{{else}}family = "mariadb10.3"{{end}}
  {{if .Spec.major_engine_version}}major_engine_version       = "{{ .Spec.major_engine_version}}"{{else}}major_engine_version="10.3"{{end}}
  {{if or (eq .Spec.instance_class "db.t2.micro") (eq .Spec.instance_class "db.t2.small") (eq .Spec.instance_class "db.t3.micro") (eq .Spec.instance_class "db.t3.small")}}performance_insights_enabled=false{{else}}performance_insights_enabled=true{{end}}
  
  disk_size        = {{ .Spec.disk_size }}
  instance_class = "{{ .Spec.instance_class }}"
  master_username       = "{{ .Spec.master_username }}"
  master_password       = "{{ .Spec.master_password }}"
  // subnet group name
  db_subnet_group_name = "{{ .Spec.name }}-db-subnet"
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