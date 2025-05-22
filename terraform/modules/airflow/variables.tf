variable "environment" {
  description = "Deployment environment prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for MWAA environment"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for MWAA environment"
  type        = list(string)
}

variable "source_bucket_arn" {
  description = "S3 bucket ARN containing DAGs and requirements"
  type        = string
}

variable "environment_class" {
  description = "MWAA environment class"
  type        = string
  default     = "mw1.small"
}