terraform {
  required_version = ">= 1.0"

  required_providers {
    aws    = ">= 3.28"
    random = "~> 2"
    null   = "~> 2"
  }
}