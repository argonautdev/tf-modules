
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
  source = "github.com/argonautdev/tf-modules.git//modules/aws/s3Bucket?ref={{.RefVersion}}"
  {{ end }}
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{.Spec.name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "S3 Bucket"
    "argonaut.dev/env/${local.env}" = "true"
  }

  aws_region = "${local.region}"

  name = "{{.Spec.name}}"

  {{ if .Spec.visibility }}
  visibility = "{{.Spec.visibility}}"
  {{ end }}
}
