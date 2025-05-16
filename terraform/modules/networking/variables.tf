variable "environment" {
  description = "Deployment environment (dev/hml/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod"
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}