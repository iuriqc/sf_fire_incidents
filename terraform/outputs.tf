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

output "glue_crawler_status" {
  description = "Glue crawler activation command"
  value       = "aws glue start-crawler --name ${module.processing.glue_crawler_name}"
}