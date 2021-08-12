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