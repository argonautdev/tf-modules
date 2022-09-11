
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env = local.environment_vars.locals.environment

  region = local.region_vars.locals.aws_region
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/cloudfront-custom-origin?ref={{.RefVersion}}"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{.Spec.name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "Cloudfront with custom origin"
    "argonaut.dev/env/${local.env}" = "true"
  }
  aws_region = "${local.region}"
  app_name = "{{.Spec.name}}"
  description = "{{.Spec.description }}"
  custom_origin_dns_name = "{{.Spec.custom_origin_dns_name }}"
  logging = "{{.Spec.logging }}"
  domain_name = "{{.Spec.domain_name }}"
  subdomain   = "{{.Spec.subdomain }}"
}
