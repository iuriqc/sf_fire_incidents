variable "environment" {
  description = "Deployment environment prefix"
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod"
  }
}

variable "glue_role_arn" {
  description = "IAM role ARN for Glue jobs"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for data storage"
  type        = string
}

variable "enable_emr" {
  description = "Whether to provision EMR cluster"
  type        = bool
  default     = false
}