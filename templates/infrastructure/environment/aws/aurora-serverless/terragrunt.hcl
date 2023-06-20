
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

terraform {

  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/aurora-serverless?ref={{.RefVersion}}"
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
    "argonaut.dev/rds-engine"  = "{{ .Spec.cluster_engine }}"
    "argonaut.dev/env" = "${local.env}"
    "env" = "${local.env}"
  }
  aws_region = "${local.region}"
  
  cluster_name = "{{ .Spec.cluster_name }}"
  
  {{if eq .Spec.cluster_engine "aurora-postgresql"}}
  // all values correspond to postgres
  create_db_cluster_parameter_group = true
  enabled_cloudwatch_logs_exports = ["postgres"]
  {{end}}
  
  {{if eq .Spec.cluster_engine "aurora-mysql"}}
  // all values correspond to mysql
  //As we know enabling logs to cloudwatch requires custom parameter group. Hence, creating one
  create_db_cluster_parameter_group = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  db_cluster_parameter_group_parameters = [
    {
      "name": "general_log",
      "value": "1"
    },
    {
      "name": "slow_query_log",
      "value": "1"
    },
    {
      "name": "server_audit_logging",
      "value": "1"
    },
    {
      "name": "server_audit_logs_upload",
      "value": "1"
    }
  ]
  {{end}}

  cluster_engine = "{{ .Spec.cluster_engine }}"
  engine_version = "{{ .Spec.engine_version }}"
  db_cluster_parameter_group_family = "{{ .Spec.db_cluster_parameter_group_family }}"
  database_name = "{{ .Spec.database_name }}"
  master_username = "{{ .Spec.master_username }}"
  master_password = "{{ .Spec.master_password }}"
  db_subnet_group_name = "${local.env}"
  cluster_min_capacity = "{{ .Spec.cluster_min_capacity }}"
  cluster_max_capacity = "{{ .Spec.cluster_max_capacity }}"
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