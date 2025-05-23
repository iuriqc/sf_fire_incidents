output "glue_job_name" {
  description = "Name of the Glue job"
  value       = aws_glue_job.sf_fire_extract.name
}

output "emr_cluster_id" {
  description = "EMR cluster ID (if enabled)"
  value       = var.enable_emr ? aws_emr_cluster.fire_etl[0].id : null
}

output "glue_database_name" {
  description = "Glue Data Catalog database name"
  value       = "fire_incidents"
}