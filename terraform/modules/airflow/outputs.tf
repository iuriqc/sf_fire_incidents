output "airflow_webserver_url" {
  description = "The webserver URL of the MWAA environment"
  value       = aws_mwaa_environment.sf_fire.webserver_url
}

output "arn" {
  description = "The ARN of the MWAA environment"
  value       = aws_mwaa_environment.sf_fire.arn
}