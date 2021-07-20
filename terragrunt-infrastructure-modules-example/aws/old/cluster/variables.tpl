variable "aws_region" {
  default = "{{.EnvironmentRegion}}"
}

variable "cluster_name" {
  default = "{{.Name}}"
  type    = string
}

variable "platform_version"{
  default = "{{.PlatformVersion}}"
  type    = string
}