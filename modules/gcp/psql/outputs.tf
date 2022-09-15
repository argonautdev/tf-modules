// Master
output "instance_name" {
  value       = module.postgresql.instance_name
  description = "The instance name for the master instance"
}

output "instance_ip_address" {
  value       = module.postgresql.instance_ip_address
  description = "The IPv4 address assigned for the master instance"
}

output "private_ip_address" {
  value       = module.postgresql.private_ip_address
  description = "The private IP address assigned for the master instance"
}

output "instance_first_ip_address" {
  value       = module.postgresql.instance_first_ip_address
  description = "The first IPv4 address of the addresses assigned for the master instance."
}

output "instance_connection_name" {
  value       = module.postgresql.instance_connection_name
  description = "The connection name of the master instance to be used in connection strings"
}

output "instance_self_link" {
  value       = module.postgresql.instance_self_link
  description = "The URI of the master instance"
}

output "instance_server_ca_cert" {
  value       = module.postgresql.instance_server_ca_cert
  description = "The CA certificate information used to connect to the SQL instance via SSL"
}

output "instance_service_account_email_address" {
  value       = module.postgresql.instance_service_account_email_address
  description = "The service account email address assigned to the master instance"
}

// Replicas
output "replicas_instance_first_ip_addresses" {
  value       = module.postgresql.replicas_instance_first_ip_addresses
  description = "The first IPv4 addresses of the addresses assigned for the replica instances"
}

output "replicas_instance_connection_names" {
  value       = module.postgresql.replicas_instance_connection_names
  description = "The connection names of the replica instances to be used in connection strings"
}

output "replicas_instance_self_links" {
  value       = module.postgresql.replicas_instance_self_links
  description = "The URIs of the replica instances"
}

output "replicas_instance_server_ca_certs" {
  value       = module.postgresql.replicas_instance_server_ca_certs
  description = "The CA certificates information used to connect to the replica instances via SSL"
}

output "replicas_instance_service_account_email_addresses" {
  value       = module.postgresql.replicas_instance_service_account_email_addresses
  description = "The service account email addresses assigned to the replica instances"
}

output "read_replica_instance_names" {
  value       = module.postgresql.read_replica_instance_names
  description = "The instance names for the read replica instances"
}

output "public_ip_address" {
  description = "The first public (PRIMARY) IPv4 address assigned for the master instance"
  value       = module.postgresql.public_ip_address
}