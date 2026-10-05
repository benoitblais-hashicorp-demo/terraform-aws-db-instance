mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id = "vpc-12345678"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id = "subnet-12345678"
    }
  }

  mock_resource "aws_security_group" {
    defaults = {
      id = "sg-12345678"
    }
  }

  mock_resource "aws_db_subnet_group" {
    defaults = {
      id   = "test-db-subnets"
      arn  = "arn:aws:rds:ca-central-1:123456789012:subgrp:test-db-subnets"
      name = "test-db-subnets"
    }
  }

  mock_resource "aws_db_instance" {
    defaults = {
      id                   = "test-postgres-instance"
      arn                  = "arn:aws:rds:ca-central-1:123456789012:db:test-postgres-instance"
      address              = "test-postgres-instance.c12345678901.ca-central-1.rds.amazonaws.com"
      endpoint             = "test-postgres-instance.c12345678901.ca-central-1.rds.amazonaws.com:5432"
      port                 = 5432
      db_name              = "appdb"
      username             = "dbadmin"
      publicly_accessible  = true
      engine               = "postgres"
      engine_version       = "16"
      instance_class       = "db.t3.micro"
      allocated_storage    = 20
      db_subnet_group_name = "test-db-subnets"
    }
  }

  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      id  = "arn:aws:secretsmanager:ca-central-1:123456789012:secret:demo/database/test-postgres-instance-123456"
      arn = "arn:aws:secretsmanager:ca-central-1:123456789012:secret:demo/database/test-postgres-instance-123456"
    }
  }

  mock_resource "aws_secretsmanager_secret_version" {
    defaults = {
      id = "arn:aws:secretsmanager:ca-central-1:123456789012:secret:demo/database/test-postgres-instance-123456|version-1"
    }
  }
}

mock_provider "random" {
  mock_resource "random_password" {
    defaults = {
      result = "mocked-random-password-123!"
    }
  }
}

# Run 1: Setup supporting networking infrastructure (VPC, Subnets, Security Group)
run "setup_networking" {
  command = apply

  module {
    source = "./tests/setup"
  }
}

# Run 2: Deploy DB instance linked to the VPC resources created in setup
run "apply_db_instance" {
  command = apply

  variables {
    identifier                   = "test-postgres-instance"
    engine                       = "postgres"
    engine_version               = "16"
    instance_class               = "db.t3.micro"
    allocated_storage            = 20
    db_name                      = "appdb"
    username                     = "dbadmin"
    publicly_accessible         = true
    create_db_subnet_group       = true
    db_subnet_group_name         = "test-db-subnets"
    subnet_ids                   = run.setup_networking.subnet_ids
    vpc_security_group_ids       = [run.setup_networking.security_group_id]
    create_db_credentials_secret = true
    skip_final_snapshot          = true
    tags = {
      Environment = "test"
      Terraform   = "true"
    }
  }

  assert {
    condition     = output.db_instance_id == "test-postgres-instance"
    error_message = "Expected db_instance_id output to match test-postgres-instance"
  }

  assert {
    condition     = output.db_instance_address == "test-postgres-instance.c12345678901.ca-central-1.rds.amazonaws.com"
    error_message = "Expected db_instance_address output to match mocked address"
  }

  assert {
    condition     = output.db_instance_port == 5432
    error_message = "Expected db_instance_port output to be 5432"
  }

  assert {
    condition     = output.db_instance_name == "appdb"
    error_message = "Expected db_instance_name output to match appdb"
  }

  assert {
    condition     = output.db_instance_username == "dbadmin"
    error_message = "Expected db_instance_username output to match dbadmin"
  }

  assert {
    condition     = output.db_subnet_group_id == "test-db-subnets"
    error_message = "Expected db_subnet_group_id output to match test-db-subnets"
  }

  assert {
    condition     = output.db_credentials_secret_arn != null
    error_message = "Expected db_credentials_secret_arn output to be populated"
  }
}
