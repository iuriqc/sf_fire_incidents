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