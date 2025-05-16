resource "aws_redshift_subnet_group" "fire_warehouse" {
  name       = "sf-fire-${var.environment}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redshift" {
  name_prefix = "sf-fire-${var.environment}-redshift-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_redshift_cluster" "fire_warehouse" {
  cluster_identifier  = "sf-fire-${var.environment}"
  database_name       = "fireincidents"
  master_username     = "admin"
  master_password     = var.redshift_password
  node_type           = var.redshift_node_type
  cluster_type        = "single-node"
  number_of_nodes     = var.redshift_nodes
  
  publicly_accessible = false
  skip_final_snapshot    = true
  automated_snapshot_retention_period = 1

  vpc_security_group_ids = [aws_security_group.redshift.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.fire_warehouse.name
}

resource "aws_athena_database" "fire" {
  name   = "sf_fire_${var.environment}"
  bucket = var.s3_bucket_name

  encryption_configuration {
    encryption_option = "SSE_S3"
  }

  force_destroy = true
}

resource "aws_athena_workgroup" "fire" {
  name = "sf-fire-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.s3_bucket_name}/athena-results/"
      
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

}