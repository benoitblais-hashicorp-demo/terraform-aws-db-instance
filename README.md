<!-- BEGIN_TF_DOCS -->
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

## Documentation

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.62 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | (Optional) The allocated storage in gigabytes. | `number` | `20` | no |
| <a name="input_create"></a> [create](#input\_create) | (Optional) Whether to create the database instance and associated resources. | `bool` | `true` | no |
| <a name="input_create_db_credentials_secret"></a> [create\_db\_credentials\_secret](#input\_create\_db\_credentials\_secret) | (Optional) Controls whether to generate a random master password and store full DB credentials in AWS Secrets Manager. | `bool` | `false` | no |
| <a name="input_create_db_subnet_group"></a> [create\_db\_subnet\_group](#input\_create\_db\_subnet\_group) | (Optional) Whether to create a DB subnet group. | `bool` | `false` | no |
| <a name="input_db_instance_tags"></a> [db\_instance\_tags](#input\_db\_instance\_tags) | (Optional) Additional tags for the DB instance. | `map(string)` | `{}` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | (Optional) The DB name to create. If omitted, no database is created initially. | `string` | `"appdb"` | no |
| <a name="input_db_subnet_group_description"></a> [db\_subnet\_group\_description](#input\_db\_subnet\_group\_description) | (Optional) Description of the DB subnet group created. | `string` | `null` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | (Optional) Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If null and `create_db_subnet_group` is true, one will be created. | `string` | `null` | no |
| <a name="input_db_subnet_group_tags"></a> [db\_subnet\_group\_tags](#input\_db\_subnet\_group\_tags) | (Optional) Additional tags for the DB subnet group. | `map(string)` | `{}` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional) The database can't be deleted when this value is set to true. | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Optional) The database engine to use. | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (Optional) The engine version to use. | `string` | `"16"` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | (Optional) The name of your final DB snapshot when this DB instance is deleted. | `string` | `null` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | (Optional) The name of the RDS instance. | `string` | `null` | no |
| <a name="input_identifier_prefix"></a> [identifier\_prefix](#input\_identifier\_prefix) | (Optional) Creates a unique identifier beginning with the specified prefix. | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | (Optional) The instance type of the RDS instance. | `string` | `"db.t3.micro"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) The ARN for the KMS encryption key. If not specified, the default AWS KMS key will be used. | `string` | `null` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | (Optional) Specifies the value for Storage Autoscaling. | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | (Optional) Specifies if the RDS instance is multi-AZ. | `bool` | `false` | no |
| <a name="input_password"></a> [password](#input\_password) | (Optional) Password for the master DB user. If null and `create_db_credentials_secret` is true, a random password will be auto-generated. | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | (Optional) The port on which the DB accepts connections. | `number` | `5432` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | (Optional) Bool to control if instance is publicly accessible. Defaults to false. | `bool` | `false` | no |
| <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo) | (Optional) Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | no |
| <a name="input_secret_description"></a> [secret\_description](#input\_secret\_description) | (Optional) Description for the Secrets Manager secret storing DB credentials. | `string` | `"RDS master credentials managed by Terraform"` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | (Optional) Name for the Secrets Manager secret storing DB credentials. Defaults to `demo/database/<identifier>`. | `string` | `null` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | (Optional) Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion). | `number` | `0` | no |
| <a name="input_secret_tags"></a> [secret\_tags](#input\_secret\_tags) | (Optional) A map of tags to assign to the Secrets Manager secret. | `map(string)` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | (Optional) Determines whether a final DB snapshot is created before the DB instance is deleted. | `bool` | `true` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | (Optional) Specifies whether the DB instance is encrypted. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | (Optional) One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (general purpose SSD), or 'io1' (provisioned IOPS SSD). | `string` | `"gp2"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Optional) A list of VPC subnet IDs to create the DB subnet group in. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to all resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) Updated Terraform resource management timeouts. | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | (Optional) Username for the master DB user. | `string` | `"dbadmin"` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Optional) List of VPC security groups to associate. | `list(string)` | `[]` | no |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.db_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.db_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.master_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_credentials_secret_arn"></a> [db\_credentials\_secret\_arn](#output\_db\_credentials\_secret\_arn) | The ARN of the Secrets Manager secret storing the database credentials |
| <a name="output_db_credentials_secret_id"></a> [db\_credentials\_secret\_id](#output\_db\_credentials\_secret\_id) | The ID of the Secrets Manager secret storing the database credentials |
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The address of the RDS instance |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | The ARN of the RDS instance |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | The connection endpoint in address:port format |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The RDS instance ID |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | The database name |
| <a name="output_db_instance_password"></a> [db\_instance\_password](#output\_db\_instance\_password) | The master password for the database |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The database port |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | The master username for the database |
| <a name="output_db_subnet_group_arn"></a> [db\_subnet\_group\_arn](#output\_db\_subnet\_group\_arn) | The ARN of the db subnet group |
| <a name="output_db_subnet_group_id"></a> [db\_subnet\_group\_id](#output\_db\_subnet\_group\_id) | The db subnet group name |

<!-- markdownlint-enable -->
## External Documentation

The following external documentation was used to develop this configuration:

* [AWS Provider — Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [AWS RDS Database Instance — Terraform Resource: aws\_db\_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
* [AWS DB Subnet Group — Terraform Resource: aws\_db\_subnet\_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)
* [AWS Secrets Manager — Terraform Resource: aws\_secretsmanager\_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)
* [AWS RDS PostgreSQL — User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
<!-- END_TF_DOCS -->