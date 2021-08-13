terraform {
  required_version = ">= 0.15"

  required_providers {
    aws        = ">= 3.40.0"
    local      = ">= 1.4"
    kubernetes = ">= 1.21"
    random     = ">= 2.1"
  }
}
