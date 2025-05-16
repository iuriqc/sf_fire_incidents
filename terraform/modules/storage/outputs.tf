output "data_bucket_name" {
  description = "S3 bucket name for raw/processed data"
  value       = aws_s3_bucket.data.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table for job metadata"
  value       = var.enable_dynamodb ? aws_dynamodb_table.etl_metadata[0].name : null
}

output "bucket_arn" {
  description = "S3 bucket ARN for IAM policies"
  value       = aws_s3_bucket.data.arn
}