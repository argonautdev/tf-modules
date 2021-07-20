variable "capacity" {
  {{ if .IsSpot }}
    default = "SPOT"
  {{else}}
    default = "ON_DEMAND"
  {{end}}
  type    = string
}

variable "disk" {
  default = {{.Disk}}
  type    = number
}

variable "instance" {
  default = "{{.Instance}}"
  type    = string
}

variable "min" {
  default = {{.Min}}
  type    = number
}

variable "max" {
  default = {{.Max}}
  type    = number
}

variable "desired" {
  default = {{.Desired}}
  type    = number
}

variable "aws_region" {
  default = "{{.EnvironmentRegion}}"
}