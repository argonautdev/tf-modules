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
  {{ if .Spec.source }}
  source = "{{ .Spec.source }}"
  {{ else }}
  source = "github.com/argonautdev/tf-modules.git//modules/aws/s3StaticSite?ref={{.RefVersion}}"
  {{ end }}
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{ .Spec.name }}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "s3-static-site"
    "argonaut.dev/env/${local.env}" = "true"
  }

  visibility = "{{ .Spec.visibility }}"

  aws_region = "${local.region}"
  name = "{{ .Spec.Name }}"
  log_bucket_name = "{{ .Spec.log_bucket_name }}"

  index_document = "{{ .Spec.index_document }}"
  error_document = "{{ .Spec.error_document }}"
  website = "{{ .Spec.website }}"
}