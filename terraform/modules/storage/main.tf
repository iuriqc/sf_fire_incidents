resource "aws_s3_bucket" "data" {
  bucket = "sf-fire-${var.environment}-data"
  acl    = "private"

  lifecycle_rule {
    id      = "auto-tiering"
    status  = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "etl_metadata" {
  name           = "sf-fire-${var.environment}-metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "JobId"

  attribute {
    name = "JobId"
    type = "S"
  }
}