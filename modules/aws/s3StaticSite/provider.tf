terraform {
  required_version = ">= 0.15"
}

provider "aws" {
  region = var.aws_region
}
