################################################################################
# Required Variables
################################################################################

# No required variables (all variables have default values)

################################################################################
# Optional Variables
################################################################################

variable "allocated_storage" {
  description = "(Optional) The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "create" {
  description = "(Optional) Whether to create the database instance and associated resources."
  type        = bool
  default     = true
}

variable "create_db_credentials_secret" {
  description = "(Optional) Controls whether to generate a random master password and store full DB credentials in AWS Secrets Manager."
  type        = bool
  default     = false
}

variable "create_db_subnet_group" {
  description = "(Optional) Whether to create a DB subnet group."
  type        = bool
  default     = false
}

variable "db_instance_tags" {
  description = "(Optional) Additional tags for the DB instance."
  type        = map(string)
  default     = {}
}

variable "db_name" {
  description = "(Optional) The DB name to create. If omitted, no database is created initially."
  type        = string
  default     = "appdb"
}

variable "db_subnet_group_description" {
  description = "(Optional) Description of the DB subnet group created."
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "(Optional) Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If null and `create_db_subnet_group` is true, one will be created."
  type        = string
  default     = null
}

variable "db_subnet_group_tags" {
  description = "(Optional) Additional tags for the DB subnet group."
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "(Optional) The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "engine" {
  description = "(Optional) The database engine to use."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "(Optional) The engine version to use."
  type        = string
  default     = "16"
}

variable "final_snapshot_identifier" {
  description = "(Optional) The name of your final DB snapshot when this DB instance is deleted."
  type        = string
  default     = null
}

variable "identifier" {
  description = "(Optional) The name of the RDS instance."
  type        = string
  default     = null
}

variable "identifier_prefix" {
  description = "(Optional) Creates a unique identifier beginning with the specified prefix."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "(Optional) The instance type of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "kms_key_id" {
  description = "(Optional) The ARN for the KMS encryption key. If not specified, the default AWS KMS key will be used."
  type        = string
  default     = null
}

variable "max_allocated_storage" {
  description = "(Optional) Specifies the value for Storage Autoscaling."
  type        = number
  default     = 0
}

variable "multi_az" {
  description = "(Optional) Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

variable "password" {
  description = "(Optional) Password for the master DB user. If null and `create_db_credentials_secret` is true, a random password will be auto-generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  description = "(Optional) The port on which the DB accepts connections."
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "(Optional) Bool to control if instance is publicly accessible. Defaults to false."
  type        = bool
  default     = false
}

variable "putin_khuylo" {
  description = "(Optional) Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}

variable "secret_description" {
  description = "(Optional) Description for the Secrets Manager secret storing DB credentials."
  type        = string
  default     = "RDS master credentials managed by Terraform"
}

variable "secret_name" {
  description = "(Optional) Name for the Secrets Manager secret storing DB credentials. Defaults to `demo/database/<identifier>`."
  type        = string
  default     = null
}

variable "secret_recovery_window_in_days" {
  description = "(Optional) Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion)."
  type        = number
  default     = 0
}

variable "secret_tags" {
  description = "(Optional) A map of tags to assign to the Secrets Manager secret."
  type        = map(string)
  default     = {}
}

variable "skip_final_snapshot" {
  description = "(Optional) Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "(Optional) Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "(Optional) One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  type        = string
  default     = "gp2"
}

variable "subnet_ids" {
  description = "(Optional) A list of VPC subnet IDs to create the DB subnet group in."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts."
  type        = map(string)
  default     = {}
}

variable "username" {
  description = "(Optional) Username for the master DB user."
  type        = string
  default     = "dbadmin"
}

variable "vpc_security_group_ids" {
  description = "(Optional) List of VPC security groups to associate."
  type        = list(string)
  default     = []
}
