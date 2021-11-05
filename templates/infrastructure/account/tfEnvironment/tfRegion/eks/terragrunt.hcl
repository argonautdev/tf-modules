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
  source = "github.com/argonautdev/tf-modules.git//modules/aws/eks?ref={{.RefVersion}}"
}

dependency "vpc" {
  config_path = "../vpc"
   mock_outputs = {
    vpc_id = "temporary-dummy-id",
    private_subnets = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"]
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{.Spec.name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "EKS Cluster"
    "argonaut.dev/env/${local.env}" = "true"
  }

  spot_tags = {
    "k8s.io/cluster-autoscaler/node-template/label/lifecycle": "Ec2Spot"
    "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot": "true"
    "k8s.io/cluster-autoscaler/node-template/label/gpu-count": "0"
    "k8s.io/cluster-autoscaler/node-template/taint/spotInstance": "true:PreferNoSchedule"
    "k8s.io/cluster-autoscaler/enabled": "true"
  }

  on_demand_tags = {
    # EC2 tags required for cluster-autoscaler auto-discovery
    "k8s.io/cluster-autoscaler/node-template/label/lifecycle": "OnDemand"
    "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot": "false"
    "k8s.io/cluster-autoscaler/node-template/label/gpu-count": "0"
    "k8s.io/cluster-autoscaler/enabled": "true"
  }

  spot_labels = {
    "lifecycle": "Ec2Spot"
    "aws.amazon.com/spot": "true"
  }

  env = "${local.env}"
  vpc = {
    name    = "${local.env}"
    id      = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.private_subnets
  }

  cluster = {
    name = "{{.Spec.name}}"
    version = "1.21" # "{ {.Spec.PlatformVersion} }" TODO: add platform version
  }

  k8s_service_account_name = "{{.Spec.name}}-argonaut-sa"

  node_group = {
    name_prefix = "{{.Spec.node_group.name}}"
    desired_capacity = {{.Spec.node_group.number_of_instance}}
    max_capacity = {{.Spec.node_group.number_of_instance_max}}
    min_capacity = {{.Spec.node_group.number_of_instance_min}}
    disk_size = {{.Spec.node_group.disk_size}}
    instance_type = "{{.Spec.node_group.instance_type}}"
    spot = {{.Spec.node_group.spot}}
  }

  # account level spec kept at account level
  map_users = local.map_users
  map_accounts = local.map_accounts

  aws_region = "${local.region}"
}

