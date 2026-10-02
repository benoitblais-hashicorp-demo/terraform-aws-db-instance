mock_provider "aws" {}
mock_provider "random" {}

variables {
  identifier = "test-postgres"
  subnet_ids = ["subnet-11111111", "subnet-22222222"]
}

run "validate_default_creation" {
  command = plan

  assert {
    condition     = length(aws_db_instance.this) == 1
    error_message = "RDS instance was not planned for creation"
  }

  assert {
    condition     = aws_db_instance.this[0].publicly_accessible == false
    error_message = "RDS instance should have publicly_accessible set to false by default"
  }

  assert {
    condition     = length(aws_secretsmanager_secret.db_credentials) == 0
    error_message = "Secrets Manager secret should not be created by default"
  }
}

run "validate_public_access_and_credentials_secret" {
  command = plan

  variables {
    publicly_accessible          = true
    create_db_credentials_secret = true
  }

  assert {
    condition     = aws_db_instance.this[0].publicly_accessible == true
    error_message = "RDS instance should allow publicly_accessible to be true"
  }

  assert {
    condition     = length(aws_secretsmanager_secret.db_credentials) == 1
    error_message = "Secrets Manager secret should be planned for creation"
  }

  assert {
    condition     = aws_secretsmanager_secret.db_credentials[0].name == "demo/database/test-postgres"
    error_message = "Secret name does not match expected format"
  }
}
