provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}

##Adding the below to limit the terrform version to use + allow optional attributes in type 'object'
terraform {
  required_version = ">= 1.0"
  experiments = [module_variable_optional_attrs]
}