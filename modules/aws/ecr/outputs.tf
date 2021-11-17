output "ecr_repositories" {
  value = module.ecr
}
output "ecr_replication" {
  value = aws_ecr_replication_configuration.default
}

