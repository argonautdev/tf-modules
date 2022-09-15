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
  source = "github.com/argonautdev/tf-modules.git//modules/aws/eksAutoScaler?ref={{.RefVersion}}"
}

dependency "eks" {
  config_path = "../eks_{{.Spec.name}}"
   mock_outputs = {
    cluster_id                 = "1234"
    role_arn                   = "placeholder-role-arn"
    service_account_name       = "placeholder-service-account-name"
    cluster_endpoint           = "abcd.com"
    certificate_authority_data = "dGVtcAo="
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name"             = "cluster-autoscaler-{{.Spec.name}}"
    "argonaut.dev/manager"          = "argonaut.dev"
    "argonaut.dev/type"             = "EKS Cluster Autoscaler"
    "argonaut.dev/env/${local.env}" = "true"
  }

  aws_region = "${local.region}"

  aws_account_id = local.map_accounts[0]

  eks = {
    id                         = dependency.eks.outputs.cluster_id
    endpoint                   = dependency.eks.outputs.cluster_endpoint
    certificate_authority_data = dependency.eks.outputs.certificate_authority_data
  }

  role_arn             = dependency.eks.outputs.role_arn
  service_account_name = dependency.eks.outputs.service_account_name
}
