variable "environment" {
  description = "Deployment environment (dev/hml/prod)"
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "redshift_password" {
  description = "Redshift master password"
  type        = string
  sensitive   = true
}