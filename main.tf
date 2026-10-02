locals {
  create = var.create && var.putin_khuylo
  tags   = merge(var.tags, { terraform-aws-modules = "db-instance" })

  # Master password generation
  create_password = local.create && var.password == null
  password        = var.password != null ? var.password : try(random_password.master_password[0].result, null)

  # Subnet group
  db_subnet_group_name = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name

  # Secret name
  identifier  = coalesce(var.identifier, var.identifier_prefix, "db")
  secret_name = coalesce(var.secret_name, "demo/database/${local.identifier}")
}

################################################################################
# Random Password & Secrets Manager (Optional)
################################################################################

resource "random_password" "master_password" {
  count = local.create_password ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  count = local.create && var.create_db_credentials_secret ? 1 : 0

  name                    = local.secret_name
  description             = var.secret_description
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = merge(local.tags, var.secret_tags)
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count = local.create && var.create_db_credentials_secret ? 1 : 0

  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    username = var.username
    password = local.password
    host     = aws_db_instance.this[0].address
    port     = tostring(aws_db_instance.this[0].port)
    dbname   = aws_db_instance.this[0].db_name
    engine   = var.engine
  })

  depends_on = [aws_db_instance.this]
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  count = local.create && var.create_db_subnet_group ? 1 : 0

  name        = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids  = var.subnet_ids

  tags = merge(local.tags, var.db_subnet_group_tags)
}

################################################################################
# DB Instance
################################################################################

resource "aws_db_instance" "this" {
  count = local.create ? 1 : 0

  identifier        = var.identifier
  identifier_prefix = var.identifier_prefix

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = local.password
  port     = var.port

  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = local.db_subnet_group_name

  deletion_protection       = var.deletion_protection
  multi_az                  = var.multi_az
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  tags = merge({ "Name" = coalesce(var.identifier, var.identifier_prefix, "db") }, var.db_instance_tags, local.tags)
}
