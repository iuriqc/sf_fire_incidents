resource "aws_glue_crawler" "fire_incidents" {
  name          = "sf-fire-${var.environment}-crawler"
  role          = var.glue_role_arn
  database_name = "fire_incidents"

  s3_target {
    path = "s3://${var.s3_bucket_name}/raw/"
  }

  configuration = jsonencode({
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
    Version = 1
  })
}

resource "aws_emr_cluster" "fire_etl" {
  count         = var.enable_emr ? 1 : 0
  name          = "sf-fire-${var.environment}-etl"
  release_label = "emr-6.4.0"
  applications  = ["Spark"]
  log_uri       = "s3://${var.s3_bucket_name}/logs/"

  service_role = aws_iam_role.emr_service_role[0].arn

  ec2_attributes {
    subnet_id                         = var.subnet_ids[0]
    emr_managed_master_security_group = aws_security_group.emr.id
    emr_managed_slave_security_group = aws_security_group.emr.id
    instance_profile                  = aws_iam_instance_profile.emr.arn
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 1
  }

  auto_termination_policy {
    idle_timeout = 3600
  }
}