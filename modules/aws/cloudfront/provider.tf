terraform {
  required_version = ">= 1.0"
}

##Parameters for Providers (https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}