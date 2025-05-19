output "vpc_id" {
  description = "VPC ID for other resources"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for Redshift/EMR"
  value       = aws_subnet.private[*].id
  depends_on  = [aws_subnet.private]
}

output "public_subnet_ids" {
  description = "Public subnet IDs for Redshift/EMR"
  value       = aws_subnet.public[*].id
  depends_on  = [aws_subnet.public]
}

output "vpc_cidr_block" {
  description = "VPC CIDR for security group rules"
  value       = aws_vpc.main.cidr_block
}