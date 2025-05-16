variable "environment" {
  description = "Deployment environment prefix"
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod"
  }
}

variable "enable_dynamodb" {
  description = "Whether to create DynamoDB table"
  type        = bool
  default     = true
}