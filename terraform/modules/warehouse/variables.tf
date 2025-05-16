variable "environment" {
  description = "Deployment environment prefix"
  type        = string
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
}