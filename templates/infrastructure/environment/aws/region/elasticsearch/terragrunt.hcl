include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env = local.environment_vars.locals.environment

  region = local.region_vars.locals.aws_region
}

terraform {

  # the below config is an example of what the config should like
  # source = "./"
  source = "github.com/argonautdev/tf-modules.git//modules/aws/elasticsearch?ref={{.RefVersion}}"

}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                    = "temporary-dummy-id",
    private_subnets           = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"]
    default_security_group_id = "temporary-dummy-security-group-id"
    vpc_cidr_block            = "10.0.0.0/8"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  tags = {
    "argonaut.dev/name"                    = "{{.Spec.name}}"
    "argonaut.dev/manager"                 = "argonaut.dev"
    "argonaut.dev/type"                    = "elasticsearch"
    "argonaut.dev/env/${local.env}"        = "true"
    "argonaut.dev/env/${local.env}/region" = "${local.region}"
    # "
  }

  region                = "${local.region}"
  name                  = "{{.Spec.name}}"
  elasticsearch_version = "{{.Spec.elasticsearch_version}}"
  vpc_enabled           = {{.Spec.vpc_enabled}}

  availability_zone_count = {{.Spec.availability_zone_count}}
  instance_type           = "{{.Spec.instance_type}}" # "t3.small.elasticsearch"
  instance_count_per_az   = {{.Spec.instance_count_per_az}}
  ebs_volume_size         = {{.Spec.ebs_volume_size}}

  dedicated_master_enabled = {{.Spec.dedicated_master_enabled}}
  dedicated_master_count   = {{.Spec.dedicated_master_count}}
  dedicated_master_type    = "{{.Spec.dedicated_master_type}}" # "t3.small.elasticsearch"

  # create_iam_service_linked_role = true only for
  # the first time you create an elasticsearch cluster per account
  create_iam_service_linked_role = {{.Spec.create_iam_service_linked_role}}

  dns_zone_id                  = "{{.Spec.dns_zone_id}}"
  kibana_hostname_enabled      = {{.Spec.kibana_hostname_enabled}}
  domain_hostname_enabled      = {{.Spec.domain_hostname_enabled}}
  elasticsearch_subdomain_name = "{{.Spec.elasticsearch_subdomain_name}}"
  kibana_subdomain_name        = "{{.Spec.kibana_subdomain_name}}"

  advanced_security_options_enabled                        = {{.Spec.advanced_security_options_enabled}}
  advanced_security_options_internal_user_database_enabled = {{.Spec.advanced_security_options_internal_user_database_enabled}}
  advanced_security_options_master_user_name               = "{{.Spec.advanced_security_options_master_user_name}}"
  advanced_security_options_master_user_password           = "{{.Spec.advanced_security_options_master_user_password}}"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
    "override_main_response_version"         = "true"
  }

  security_groups     = [dependency.vpc.outputs.default_security_group_id]
  allowed_cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]

  vpc = {
    name                      = "${local.env}" #"
    id                        = dependency.vpc.outputs.vpc_id
    public_subnets            = dependency.vpc.outputs.public_subnets
    private_subnets           = dependency.vpc.outputs.private_subnets
    vpc_cidr_block            = dependency.vpc.outputs.vpc_cidr_block
    default_security_group_id = dependency.vpc.outputs.default_security_group_id
  }

}