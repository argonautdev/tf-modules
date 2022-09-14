
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
  source = "../../../..//modules/aws/aurora"
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
    "argonaut.dev/name"        = "pg"
    "argonaut.dev/rds-engine"  = "aurora-mysql"
    "argonaut.dev/type"        = "RDS-mysql"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/env"        = "dev"
    "env" = "dev"
    }

    visibility = "public"
    db_parameter_group_name = "mygroup"
    db_cluster_parameter_group_name = "mygroupcluster"

    aws_region = "us-east-1"
    storage_encrypted = true
    cluster_engine = "aurora-mysql"
    cluster_name = "<myclustername>"
    database_name = "<startingdb>"
    master_username = "myadminuser"
    master_password = "mypassword"
    backup_retention_period = 9
    create_db_subnet_group = true
    performance_insights_enabled = false
    // performance_insights_retention_period = 7

  vpc = {
    name    = "${local.env}"
    vpc_id      = dependency.vpc.outputs.vpc_id
    vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
    public_subnets = dependency.vpc.outputs.public_subnets
    private_subnets = dependency.vpc.outputs.private_subnets
    database_subnets = dependency.vpc.outputs.database_subnets
    default_security_group_id = dependency.vpc.outputs.default_security_group_id
  }

    skip_final_snapshot = false
    engine_version = "8.0.mysql_aurora.3.02.0" ## read README.md to find the command that gives available version
    db_instance_class = "db.t3.medium" ## read README.md to find the command that gives instancestypes supported for passed version above
    db_parameter_group_family = "aurora-mysql8.0"
    enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
    instances = {
        masterdb = {}
    }
    /** Autoscaling **/
    autoscaling_enabled = true
    autoscaling_max_capacity = 10
    autoscaling_min_capacity = 0
    autoscaling_scale_in_cooldown = 300
    autoscaling_scale_out_cooldown = 300
    // autoscaling_target_cpu = 5

}

