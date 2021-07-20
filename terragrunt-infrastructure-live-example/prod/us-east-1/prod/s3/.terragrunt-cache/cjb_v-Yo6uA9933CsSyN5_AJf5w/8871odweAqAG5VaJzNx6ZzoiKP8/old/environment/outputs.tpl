output "vpc" {
    value = aws_vpc.{{.Name}}-{{.UID}}.id
}

output "subnet_id" {
  value = [
    aws_subnet.{{.Name}}-{{.UID}}-subnet.*.id[0],
    aws_subnet.{{.Name}}-{{.UID}}-subnet.*.id[1]
  ]
}
