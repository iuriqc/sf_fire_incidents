output "redshift_endpoint" {
  description = "Redshift cluster endpoint"
  value       = aws_redshift_cluster.fire_warehouse.endpoint
}

output "redshift_jdbc_url" {
  description = "Redshift JDBC connection string"
  value       = "jdbc:redshift://${aws_redshift_cluster.fire_warehouse.endpoint}/${aws_redshift_cluster.fire_warehouse.database_name}"
}

output "athena_database_name" {
  description = "Athena database name"
  value       = aws_athena_database.fire.name
}

output "athena_workgroup_name" {
  description = "Athena workgroup name"
  value       = aws_athena_workgroup.fire.name
}

output "redshift_security_group_id" {
  description = "Security group ID for Redshift cluster"
  value       = aws_security_group.redshift.id
}