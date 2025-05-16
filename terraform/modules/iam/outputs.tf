output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "emr_service_role_arn" {
  description = "ARN of the EMR service role"
  value       = var.enable_emr ? aws_iam_role.emr_service_role[0].arn : null
}

output "emr_instance_profile_arn" {
  description = "ARN of the EMR EC2 instance profile"
  value       = var.enable_emr ? aws_iam_instance_profile.emr[0].arn : null
}