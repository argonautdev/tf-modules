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
  source = "github.com/argonautdev/tf-modules.git//modules/aws/msk?ref={{.RefVersion}}"
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
    "argonaut.dev/name"             = "{{.Spec.name}}"
    "argonaut.dev/manager"          = "argonaut.dev"
    "argonaut.dev/type"             = "msk"
    "argonaut.dev/env/${local.env}" = "true"
  }

  aws_region = "${local.region}"

  name = "{{.Spec.name}}"

  {{if .Spec.number_of_broker_nodes_per_zone}}number_of_broker_nodes_per_zone = {{.Spec.number_of_broker_nodes_per_zone}}{{end}}
  {{if .Spec.number_of_zones}}number_of_zones = {{.Spec.number_of_zones}}{{end}}
  {{if .Spec.kafka_version}}kafka_version = "{{.Spec.kafka_version}}"{{end}}
  {{if .Spec.broker_instance_type}}broker_instance_type = "{{.Spec.broker_instance_type}}"{{end}}
  {{if .Spec.broker_volume_size}}broker_volume_size = {{.Spec.broker_volume_size}}{{end}}
  {{if .Spec.zone_id}}zone_id = "{{.Spec.zone_id}}"{{end}}
  {{if .Spec.allowed_cidr_blocks}}allowed_cidr_blocks = [{{ range .Spec.allowed_cidr_blocks}}"{{.}}", {{end}}]{{end}}
  {{if .Spec.client_broker}}client_broker = "{{.Spec.client_broker}}"{{end}}
  {{if .Spec.encryption_in_cluster}}encryption_in_cluster= {{.Spec.encryption_in_cluster}}{{end}}
  {{if .Spec.encryption_at_rest_kms_key_arn}}encryption_at_rest_kms_key_arn = "{{.Spec.encryption_at_rest_kms_key_arn}}"{{end}}
  {{if .Spec.enhanced_monitoring}}enhanced_monitoring = "{{.Spec.enhanced_monitoring}}"{{end}}
  {{if .Spec.certificate_authority_arns}}certificate_authority_arns = [{{ range .Spec.allowed_security_groups}}"{{.}}", {{end}}]{{end}}
  {{if .Spec.client_sasl_scram_enabled}}client_sasl_scram_enabled = {{.Spec.client_sasl_scram_enabled}}{{end}}
  {{if .Spec.client_sasl_scram_secret_association_arns}}client_sasl_scram_secret_association_arns = [{{ range .Spec.client_sasl_scram_secret_association_arns}}"{{.}}", {{end}}]{{end}}
  {{if .Spec.client_tls_auth_enabled}}client_tls_auth_enabled = {{.Spec.client_tls_auth_enabled}}{{end}}
  {{if .Spec.jmx_exporter_enabled}}jmx_exporter_enabled = {{.Spec.jmx_exporter_enabled}}{{end}}
  {{if .Spec.node_exporter_enabled}}node_exporter_enabled= {{.Spec.node_exporter_enabled}}{{end}}
  {{if .Spec.cloudwatch_logs_enabled}}cloudwatch_logs_enabled= {{.Spec.cloudwatch_logs_enabled}}{{end}}
  {{if .Spec.cloudwatch_logs_log_group}}cloudwatch_logs_log_group = "{{.Spec.cloudwatch_logs_log_group}}"{{end}}
  {{if .Spec.firehose_logs_enabled}}firehose_logs_enabled = {{.Spec.firehose_logs_enabled}}{{end}}
  {{if .Spec.firehose_delivery_stream}}firehose_delivery_stream= "{{.Spec.firehose_delivery_stream}}"{{end}}
  {{if .Spec.s3_logs_enabled}}s3_logs_enabled= {{.Spec.s3_logs_enabled}}{{end}}
  {{if .Spec.s3_logs_bucket}}s3_logs_bucket= "{{.Spec.s3_logs_bucket}}"{{end}}
  {{if .Spec.s3_logs_prefix}}s3_logs_prefix= "{{.Spec.s3_logs_prefix}}"{{end}}
  {{if .Spec.properties}}properties = { {{range $key, $value := .Spec.properties}}
    "{{$key}}" = "{{$value}}",
    {{end}}}
  {{end}}
  {{if .Spec.storage_autoscaling_target_value}}storage_autoscaling_target_value = {{.Spec.storage_autoscaling_target_value}}{{end}}
  {{if .Spec.storage_autoscaling_max_capacity}}storage_autoscaling_max_capacity = {{.Spec.storage_autoscaling_max_capacity}}{{end}}
  {{if .Spec.storage_autoscaling_disable_scale_in}}storage_autoscaling_disable_scale_in = {{.Spec.storage_autoscaling_disable_scale_in}}{{end}}

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

