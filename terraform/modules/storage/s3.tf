resource "aws_s3_bucket" "sf_fire_incidents" {
    bucket = "sf-fire-incidents-${var.environment}"
    acl    = "private"

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }

    lifecycle_rule {
        id = "archive"
        enabled = true

        transition {
            days = 30
            storage_class = "STANDARD_IA"
        }

        transition {
            days = 90
            storage_class = "GLACIER"
        }
    }
}