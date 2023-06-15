terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1.2"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}
