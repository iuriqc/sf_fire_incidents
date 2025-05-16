variable "environment" {
  description = "Deployment environment prefix"
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod"
  }
}

variable "vpc_id" {
  description = "VPC ID for Redshift placement"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Redshift cluster"
  type        = list(string)
}

variable "redshift_password" {
  description = "Master password for Redshift"
  type        = string
  sensitive   = true
}

variable "redshift_node_type" {
  description = "Redshift node type"
  type        = string
  default     = "ra3.xlplus"
}

variable "redshift_nodes" {
  description = "Number of Redshift nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.redshift_nodes >= 1 && var.redshift_nodes <= 8
    error_message = "Number of nodes must be between 1 and 8"
  }
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Athena query results"
  type        = string
}