variable "environment" {
  description = "Deployment environment (dev/hml/prod)"
  type        = string
  default     = "dev"
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