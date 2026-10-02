# AWS RDS Database Instance Terraform Module

Terraform module to provision an Amazon Web Services (AWS) RDS Database Instance (e.g., PostgreSQL, MySQL, MariaDB) with DB subnet groups, optional automated master password generation, and AWS Secrets Manager integration.

## Permissions

To provision the AWS resources managed by this module, the IAM role or user running Terraform needs permissions such as:

- `AmazonRDSFullAccess` (or fine-grained privileges to manage RDS instances, DB subnet groups, parameter groups, and snapshots).
- Additional permissions to describe subnets, VPCs, and Security Groups (e.g., `ec2:DescribeSubnets`, `ec2:DescribeVpcs`, `ec2:DescribeSecurityGroups`).
- Permissions to manage AWS Secrets Manager secrets if enabling automated DB credentials generation (`secretsmanager:CreateSecret`, `secretsmanager:PutSecretValue`, `secretsmanager:DeleteSecret`, `secretsmanager:DescribeSecret`, `secretsmanager:TagResource`).

## Authentications

Authentication to AWS can be configured using one of the following methods, with preference given to OIDC and dynamic provider credentials in CI/CD environments.

### HCP Terraform / Terraform Enterprise Dynamic Credentials (OIDC)

Use dynamic provider credentials via OpenID Connect (OIDC) for secure, short-lived credentials when running in HCP Terraform or Terraform Enterprise.

- **Using environment variables (HCP Terraform Workspace)**

  - `TFC_AWS_PROVIDER_AUTH=true`
  - `TFC_AWS_RUN_ROLE_ARN=<aws-iam-role-arn>`

### OIDC with GitHub Actions

When using GitHub Actions, configure OIDC via the `aws-actions/configure-aws-credentials` action.

- **Using GitHub Actions**

  ```yaml
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::111122223333:role/github-actions-role
      aws-region: us-east-1
  ```

### Static Access Keys

For local development or environments not supporting OIDC, use static IAM programmatic access keys.

- **Inside the provider block**

  ```hcl
  provider "aws" {
    region     = "us-east-1"
    access_key = "<aws-access-key-id>"
    secret_key = "<aws-secret-access-key>"
  }
  ```

- **Using environment variables**

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION` (optional)

Documentation:

- [AWS Provider Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)
- [Dynamic Provider Credentials in HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration)

## Features

- Complete foundational AWS RDS database instance deployment.
- DB Subnet Group creation or association with existing DB Subnet Group.
- Configurable public accessibility (`publicly_accessible = false` by default).
- Automated master password generation with secure random strings.
- Integration with AWS Secrets Manager storing database connection parameters (host, port, username, password, dbname, engine).
- Encryption at rest via KMS and storage autoscaling support.

## Usage example

### Example 1: Private PostgreSQL RDS Instance

```hcl
module "db" {
  source  = "app.terraform.io/benoitblais-hashicorp/db-instance/aws"
  version = "~> 0.0"

  identifier     = "prod-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  db_name           = "appdb"
  username          = "dbadmin"

  # Subnets & Security
  create_db_subnet_group = true
  subnet_ids             = ["subnet-12345678", "subnet-87654321"]
  vpc_security_group_ids = ["sg-12345678"]

  # Security & Credentials
  publicly_accessible          = false
  create_db_credentials_secret = true

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
```

### Example 2: Publicly Accessible RDS Instance with Existing Subnet Group

```hcl
module "db" {
  source  = "app.terraform.io/benoitblais-hashicorp/db-instance/aws"
  version = "~> 0.0"

  identifier     = "static-demo-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  db_name           = "appdb"
  username          = "dbadmin"

  publicly_accessible          = true
  create_db_subnet_group       = true
  db_subnet_group_name         = "public-db-subnets"
  subnet_ids                   = ["subnet-12345678", "subnet-87654321"]
  vpc_security_group_ids       = ["sg-12345678"]
  create_db_credentials_secret = true
  skip_final_snapshot          = true
}
```
