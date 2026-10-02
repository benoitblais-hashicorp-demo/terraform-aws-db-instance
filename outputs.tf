output "db_instance_id" {
  description = "The RDS instance ID"
  value       = try(aws_db_instance.this[0].id, null)
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = try(aws_db_instance.this[0].arn, null)
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = try(aws_db_instance.this[0].address, null)
}

output "db_instance_endpoint" {
  description = "The connection endpoint in address:port format"
  value       = try(aws_db_instance.this[0].endpoint, null)
}

output "db_instance_port" {
  description = "The database port"
  value       = try(aws_db_instance.this[0].port, null)
}

output "db_instance_name" {
  description = "The database name"
  value       = try(aws_db_instance.this[0].db_name, null)
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = try(aws_db_instance.this[0].username, null)
  sensitive   = true
}

output "db_instance_password" {
  description = "The master password for the database"
  value       = local.password
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = try(aws_db_subnet_group.this[0].id, null)
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = try(aws_db_subnet_group.this[0].arn, null)
}

################################################################################
# Secrets Manager Credentials
################################################################################

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the database credentials"
  value       = try(aws_secretsmanager_secret.db_credentials[0].arn, null)
}

output "db_credentials_secret_id" {
  description = "The ID of the Secrets Manager secret storing the database credentials"
  value       = try(aws_secretsmanager_secret.db_credentials[0].id, null)
}
