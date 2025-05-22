resource "aws_mwaa_environment" "sf_fire" {
  name = "sf-fire-${var.environment}"
  
  airflow_configuration_options = {
    "core.load_default_connections" = "false"
    "core.load_examples"           = "false"
    "webserver.dag_default_view"   = "tree"
    "webserver.dag_orientation"    = "TB"
  }

  dag_s3_path        = "dags"
  requirements_s3_path = "requirements/aws_requirements.txt"

  execution_role_arn = aws_iam_role.mwaa_role.arn
  source_bucket_arn  = var.source_bucket_arn

  environment_class = var.environment_class

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = var.subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }
}

resource "aws_security_group" "mwaa" {
  name_prefix = "sf-fire-${var.environment}-mwaa-"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "mwaa_role" {
  name = "sf-fire-${var.environment}-mwaa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "airflow-env.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "mwaa_policy" {
  name = "sf-fire-${var.environment}-mwaa-policy"
  role = aws_iam_role.mwaa_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject*",
          "s3:ListBucket",
          "s3:PutObject*",
          "redshift:*",
          "glue:*",
          "logs:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}