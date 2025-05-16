resource "aws_iam_role" "glue_role" {
  name = "${var.role_name_prefix}-${var.environment}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role" "emr_service_role" {
  count = var.enable_emr ? 1 : 0
  name = "${var.role_name_prefix}-${var.environment}-emr-service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_service" {
  count      = var.enable_emr ? 1 : 0
  role       = aws_iam_role.emr_service_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role" "emr_ec2_role" {
  count = var.enable_emr ? 1 : 0
  name = "${var.role_name_prefix}-${var.environment}-emr-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_ec2" {
  count = var.enable_emr ? 1 : 0
  role       = aws_iam_role.emr_ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "emr" {
  count = var.enable_emr ? 1 : 0
  name = "${var.role_name_prefix}-${var.environment}-emr-profile"
  role = aws_iam_role.emr_ec2_role[0].name
}