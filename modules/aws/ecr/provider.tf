terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.64.2"
    }
  }
  // experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}