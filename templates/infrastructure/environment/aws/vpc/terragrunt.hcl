
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  map_users    = local.account_vars.locals.map_users
  map_accounts = local.account_vars.locals.map_accounts

  env = local.environment_vars.locals.environment

  region = "{{.Region}}"
  
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/vpc/{{if .Spec.is_imported}}{{.Spec.import_kind}}{{else}}default{{end}}?ref={{.RefVersion}}"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name"        = "${local.env}"
    "argonaut.dev/type"        = "VPC"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "${local.env}"
  }
  aws_region                 = "${local.region}"
  # vpc name should be same as env name
  name                       = "${local.env}"
  enable_vpn_gateway         = true
  public_subnet_count        = 3
  private_subnet_count       = 3
  
  create_database_subnet_group = true
  create_database_subnet_route_table     = true
  enable_dns_hostnames       = true
  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_support         = true
  create_database_internet_gateway_route = true

  map_public_ip_on_launch = true

  cidr_block = {{if .Spec.is_imported}}"{{ .Spec.cidr_block}}"{{else}}"10.0.0.0/16"{{end}}
  public_subnet_cidr_blocks = {{if .Spec.is_imported}}[{{ range .Spec.public_subnet_cidr_blocks}}"{{.}}", {{end}}]{{else}}["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]{{end}}
  private_subnet_cidr_blocks = {{if .Spec.is_imported}}[{{ range .Spec.private_subnet_cidr_blocks}}"{{.}}", {{end}}]{{else}}["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]{{end}}
  database_subnet_cidr_blocks = {{if .Spec.is_imported}}[{{ range .Spec.database_subnet_cidr_blocks}}"{{.}}", {{end}}]{{else}}["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]{{end}}
  elasticache_subnet_cidr_blocks = {{if .Spec.is_imported}}[{{ range .Spec.elasticache_subnet_cidr_blocks}}"{{.}}", {{end}}]{{else}}["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]{{end}}

  {{if .Spec.is_imported}}import_security_group_id = "{{ .Spec.import_security_group_id}}"{{end}}
  {{if .Spec.is_imported}}import_vpc_id = "{{ .Spec.import_vpc_id}}"{{end}}

}
