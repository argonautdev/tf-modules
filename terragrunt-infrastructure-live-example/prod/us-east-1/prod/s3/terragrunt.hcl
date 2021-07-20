locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
  region = local.region_vars.locals.aws_region
  name = "w4567yuhb9ioksad"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../terragrunt-infrastructure-modules-example/aws//s3Bucket"

}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name          = "${local.name}"
  aws_region = "${local.region}"

  visibility = "public"

  default_tags = {
    "argonaut.dev/name"        = "${local.name}"
    "argonaut.dev/type"        = "s3"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "${local.env}"
  }
}
