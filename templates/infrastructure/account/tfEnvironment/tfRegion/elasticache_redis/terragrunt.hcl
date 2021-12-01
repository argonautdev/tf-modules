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
terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/elasticacheRedis?ref={{.RefVersion}}"
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
    "argonaut.dev/name" = "{{.Spec.name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "Elasticache Redis"
    "argonaut.dev/env/${local.env}" = "true"
  }

  aws_region = "${local.region}"

  name = "{{.Spec.name}}"

  {{if .Spec.engine_version}}engine_version = "{{.Spec.engine_version}}"{{end}}
  {{if .Spec.engine_version}}family = "redis{{.Spec.engine_version}}"{{end}}
  {{if .Spec.engine_version}}parameter_group_name = "default.redis{{.Spec.engine_version}}"{{end}}

  instance_type = "{{.Spec.node_type}}"
  cluster_size = {{.Spec.num_cache_nodes}}
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false
  cloudwatch_metric_alarms_enabled = true

  parameter=[{{ range $p := .Spec.parameter }}
    {
      name  = "{{$p.key}}"
      value = "{{$p.value}}"
    },
  {{ end }}
  ]

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

