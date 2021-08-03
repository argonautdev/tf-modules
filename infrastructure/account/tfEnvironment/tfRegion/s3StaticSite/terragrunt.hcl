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

include {
  path = find_in_parent_folders("backend.hcl")
}

terraform {

  # the below config is an example of what the config should like
  # source = "git::git@github.com:gruntwork-io/tf-modules.git//modules/aws/env_cluster_nodegroup?ref=v0.4.0"
  source = "github.com/argonautdev/tf-modules.git//modules/aws/s3StaticSite?ref={{.RefVersion}}"

  # source = "/Users/akash.patro/Code/argonaut/tf-modules//modules/aws/s3StaticSite"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{ .AwsS3StaticSite.Name }}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "s3-static-site"
    "argonaut.dev/env/${local.env}" = "true"
  }

  visibility = "{{ .AwsS3StaticSite.Visibility }}"

  aws_region = "${local.region}"
  name = "{{ .AwsS3StaticSite.Name }}"
  log_bucket_name = "{{ .AwsS3StaticSite.LogBucketName }}"

  index_document = "{{ .AwsS3StaticSite.IndexDocument }}"
  error_document = "{{ .AwsS3StaticSite.ErrorDocument }}"
  website = "{{ .AwsS3StaticSite.Website }}"
}