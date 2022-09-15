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

  region = "{{.Region}}"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/document_db?ref={{.RefVersion}}"
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
    "argonaut.dev/name" = "{{.Spec.name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "DocumentDB"
    "argonaut.dev/env/${local.env}" = "true"
  }

  aws_region = "${local.region}"

  name = "{{.Spec.name}}"

  {{if .Spec.zone_id}}zone_id= "{{.Spec.zone_id}}"{{end}}
  {{if .Spec.allowed_security_groups}}allowed_security_groups={{.Spec.allowed_security_groups}}{{end}}
  {{if .Spec.allowed_cidr_blocks}}allowed_cidr_blocks= {{.Spec.allowed_cidr_blocks}}{{end}}
  {{if .Spec.instance_class}}instance_class="{{.Spec.instance_class}}"{{end}}
  {{if .Spec.cluster_size}}cluster_size={{.Spec.cluster_size}}{{end}}
  {{if .Spec.snapshot_identifier}}snapshot_identifier={{.Spec.snapshot_identifier}}{{end}}
  {{if .Spec.db_port}}db_port={{.Spec.db_port}}{{end}}
  master_username="{{.Spec.master_username}}"
  master_password="{{.Spec.master_password}}"
  {{if .Spec.retention_period}}retention_period={{.Spec.retention_period}}{{end}}
  {{if .Spec.preferred_backup_window}}preferred_backup_window="{{.Spec.preferred_backup_window}}"{{end}}
  {{if .Spec.preferred_maintenance_window}}preferred_maintenance_window="{{.Spec.preferred_maintenance_window}}"{{end}}
  {{if .Spec.cluster_parameters}}cluster_parameters=[{{range $p := .Spec.cluster_parameters}}
    {
      apply_method = "{{$p.apply_method}}"
      name = "{{$p.name}}"
      value = "{{$p.value}}"
    },
    {{end}}]
  {{end}}
  {{if .Spec.cluster_family}}cluster_family="{{.Spec.cluster_family}}"{{end}}
  {{if .Spec.engine}}engine="{{.Spec.engine}}"{{end}}
  {{if .Spec.engine_version}}engine_version="{{.Spec.engine_version}}"{{end}}
  {{if .Spec.storage_encrypted}}storage_encrypted={{.Spec.storage_encrypted}}{{end}}
  {{if .Spec.kms_key_id}}kms_key_id="{{.Spec.kms_key_id}}"{{end}}
  {{if .Spec.skip_final_snapshot}}skip_final_snapshot={{.Spec.skip_final_snapshot}}{{end}}
  {{if .Spec.deletion_protection}}deletion_protection={{.Spec.deletion_protection}}{{end}}
  {{if .Spec.apply_immediately}}apply_immediately={{.Spec.apply_immediately}}{{end}}
  {{if .Spec.auto_minor_version_upgrade}}auto_minor_version_upgrade={{.Spec.auto_minor_version_upgrade}}{{end}}
  {{if .Spec.enabled_cloudwatch_logs_exports}}enabled_cloudwatch_logs_exports={{.Spec.enabled_cloudwatch_logs_exports}}{{end}}
  {{if .Spec.cluster_dns_name}}cluster_dns_name="{{.Spec.cluster_dns_name}}"{{end}}
  {{if .Spec.reader_dns_name}}reader_dns_name="{{.Spec.reader_dns_name}}"{{end}}

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

