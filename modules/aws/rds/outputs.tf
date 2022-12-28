output "rds_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.db_instance_address
}

output "rds_instance_port" {
  description = "The database port"
  value       = module.db.db_instance_port
}

output "rds_instance_username" {
  description = "The master username for the database"
  value       = module.db.db_instance_username
  sensitive = true
}

output "rds_instance_password" {
  description = "The master password"
  value       = module.db.db_instance_password
  sensitive   = true
}

output "rds_instance_identifier" {
  description = "RDS Instance Identifier"
  value       = var.identifier
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.db.db_instance_id
}

output "db_instance_database_name" {
  description = "The database name"
  value       = module.db.db_instance_name
}
