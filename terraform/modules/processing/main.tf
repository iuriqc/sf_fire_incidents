resource "aws_glue_job" "sf_fire_extract" {
  name              = "sf-fire-extract-${var.environment}"
  role_arn          = var.glue_role_arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    script_location = "s3://${var.s3_bucket_name}/scripts/sf_fire_extract.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"         = "python"
    "--continuous-log-logGroup"  = "/aws-glue/jobs/sf-fire-extract"
    "--enable-job-insights"  = "true"
    "--job-bookmark-option"  = "job-bookmark-enable"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_security_group" "emr" {
  name_prefix = "sf-fire-${var.environment}-emr-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_emr_cluster" "fire_etl" {
  count         = var.enable_emr ? 1 : 0
  name          = "sf-fire-${var.environment}-etl"
  release_label = "emr-6.4.0"
  applications  = ["Spark"]
  log_uri       = "s3://${var.s3_bucket_name}/logs/"

  service_role = var.emr_service_role_arn

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = aws_security_group.emr.id
    emr_managed_slave_security_group  = aws_security_group.emr.id
    instance_profile                  = var.emr_instance_profile_arn
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