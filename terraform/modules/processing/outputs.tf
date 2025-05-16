output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.fire_incidents.name
}

output "emr_cluster_id" {
  description = "EMR cluster ID (if enabled)"
  value       = var.enable_emr ? aws_emr_cluster.fire_etl.id : null
}

output "glue_database_name" {
  description = "Glue Data Catalog database name"
  value       = "fire_incidents"
}