output "s3_data_bucket" {
  description = "Name of the S3 data bucket"
  value       = module.storage.data_bucket_name
}

output "redshift_connection" {
  description = "Redshift connection details"
  value = {
    endpoint = module.warehouse.redshift_endpoint
    jdbc_url = module.warehouse.redshift_jdbc_url
    database = "fireincidents"
  }
  sensitive = true
}

output "glue_job_status" {
  description = "Glue job execution command"
  value       = "aws glue start-job-run --job-name ${module.processing.glue_job_name}"
}

locals {
  config = jsondecode(file("${path.module}/terraform.conf"))
}

output "config_action" {
  value = local.config.action
}