terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = ">= 3.35.0"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}
