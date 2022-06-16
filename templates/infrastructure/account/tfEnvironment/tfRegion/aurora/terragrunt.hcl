
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

  source = "github.com/argonautdev/tf-modules.git//modules/aws/aurora?ref={{.RefVersion}}"
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
    "argonaut.dev/type"        = "{{ .Spec.type }}"
    "argonaut.dev/rds-engine"  = "{{ .Spec.engine }}"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/env/${local.env}" = "true"
    }
    aws_region = "${local.region}"

    visibility = "{{ .Spec.visibility}}"

    cluster_name = "{{ .Spec.cluster_name}}"
    {{if .Spec.db_parameter_group_name}} db_parameter_group_name = "{{ .Spec.db_parameter_group_name}}"{{end}}
    db_parameter_group_family = "{{ .Spec.db_parameter_group_family}}"
    db_cluster_parameter_group_name = "{{ .Spec.db_cluster_parameter_group_name}}"

    {{if .Spec.storage_encrypted}}storage_encrypted={{ .Spec.storage_encrypted}}{{end}}
    cluster_engine = "{{ .Spec.engine}}"
    engine_version = "{{ .Spec.engine_version}}"

    database_name = "{{ .Spec.database_name}}"
    master_username = "{{ .Spec.master_username}}"
    master_password = "{{ .Spec.master_password}}"
    {{if .Spec.backup_retention_period }}backup_retention_period={{ .Spec.backup_retention_period}}{{end}}
    {{if .Spec.skip_final_snapshot}}skip_final_snapshot={{ .Spec.skip_final_snapshot}}{{end}}

    db_instance_class = "{{ .Spec.db_instance_class }}"
    instances = {
        masterdb = {},
        primaryReplica = {}
    }

    {{if eq .Spec.engine "aurora-mysql"}}
    performance_insights_enabled = false
    enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
    {{end}}

    /** Autoscaling **/
    {{if .Spec.autoscaling_enabled}}autoscaling_enabled = {{ .Spec.autoscaling_enabled}}{{end}}
    {{if .Spec.autoscaling_max_capacity}}autoscaling_max_capacity = {{ .Spec.autoscaling_max_capacity}}{{end}}
    {{if .Spec.autoscaling_min_capacity}}autoscaling_min_capacity = {{ .Spec.autoscaling_min_capacity}}{{end}}
    {{if .Spec.autoscaling_scale_in_cooldown}}autoscaling_scale_in_cooldown = {{ .Spec.autoscaling_scale_in_cooldown}}{{end}}
    {{if .Spec.autoscaling_scale_out_cooldown}}autoscaling_scale_out_cooldown={{ .Spec.autoscaling_scale_out_cooldown}}{{end}}

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