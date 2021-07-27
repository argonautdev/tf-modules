terraform {
  required_version = ">= 0.15"

  required_providers {
    aws        = ">= 3.22.0"
    random     = ">= 2.1"
    kubernetes = "~> 1.11"
  }
}

provider "aws" {
  region = var.aws_region
}
