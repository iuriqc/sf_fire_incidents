variable "environment" {
  description = "Deployment environment prefix"
  type        = string
  default     = "dev"
}

variable "enable_dynamodb" {
  description = "Whether to create DynamoDB table"
  type        = bool
  default     = true
}