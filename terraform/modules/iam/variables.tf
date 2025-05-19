variable "environment" {
  description = "Deployment environment prefix"
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "Environment must be one of: dev, hml, prod"
  }
}

variable "enable_emr" {
  description = "Whether to create EMR related roles"
  type        = bool
  default     = false
}

variable "role_name_prefix" {
  description = "Prefix for IAM role names"
  type        = string
  default     = "sf-fire"
}