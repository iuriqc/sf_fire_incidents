resource "aws_redshift_cluster" "fire_warehouse" {
  cluster_identifier  = "sf-fire-${var.environment}"
  database_name       = "fireincidents"
  master_username     = "admin"
  master_password     = var.redshift_password
  node_type           = "ra3.xlplus"
  cluster_type        = "single-node"
  publicly_accessible = false

  skip_final_snapshot    = true
  automated_snapshot_retention_period = 1

  vpc_security_group_ids = [aws_security_group.redshift.id]
}

resource "aws_athena_database" "fire" {
  name   = "sf_fire_${var.environment}"
  bucket = var.s3_bucket_name
}