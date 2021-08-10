variable "aws_region" {
  description = "provider region"
}

variable "aws_account_id" {
  type = string
}

variable "eks" {
  description = "All cluster info (singular)"
  type = object({
    id = string
  })
}

variable "role_arn" {
  type = string
}

variable "service_account_name" {
  type = string
}
