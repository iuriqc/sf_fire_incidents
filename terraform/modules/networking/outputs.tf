output "vpc_id" {
  description = "VPC ID for other resources"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for Redshift/EMR"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for Redshift/EMR"
  value       = aws_subnet.public[*].id
}

output "vpc_cidr_block" {
  description = "VPC CIDR for security group rules"
  value       = aws_vpc.main.cidr_block
}