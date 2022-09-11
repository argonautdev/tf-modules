
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
  source = "github.com/argonautdev/tf-modules.git//modules/aws/cloudfront-s3?ref={{.RefVersion}}"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{.Spec.name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "Cloudfront with S3"
    "argonaut.dev/env/${local.env}" = "true"
  }
  aws_region = "${local.region}"
  app_name = "{{.Spec.name}}"
  create_origin_access_identity = true
  description = "{{.Spec.description }}"
  cf_origin_create_bucket = "{{.Spec.cf_origin_create_bucket }}"
  cf_origin_bucket_name = "{{.Spec.cf_origin_bucket_name }}"
  attach_policy = "{{.Spec.attach_policy }}"
  default_root_object = "{{.Spec.default_root_object }}"
  logging = "{{.Spec.logging }}"
  domain_name = "{{.Spec.domain_name }}"
  subdomain   = "{{.Spec.subdomain }}"
}
