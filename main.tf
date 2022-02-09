
resource "aws_s3_bucket" "bucket_landing" {
  bucket = "${var.application_name}-s3-land-${var.deployment_environment}"
  acl    = "private"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "bucket_code" {
  bucket = "${var.application_name}-s3-code-${var.deployment_environment}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "bucket_object" {
    for_each = fileset("assets/", "*")
    bucket = aws_s3_bucket.bucket_code.id
    key = each.value
    source = "assets/${each.value}"
    etag = filemd5("assets/${each.value}")
}

resource "aws_iam_role" "application-role" {
  name = "custrole-${var.application_name}-${var.deployment_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_glue_catalog_database" "glue-database" {
  name = "airtable-${var.application_name}-${var.deployment_environment}"
}

resource "aws_glue_crawler" "glue-crawler" {
  database_name = aws_glue_catalog_database.glue-database.name
  name          = "airtable-${var.application_name}-${var.deployment_environment}"
  role          = aws_iam_role.application-role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.bucket_landing.bucket}"
  }
}

resource "aws_glue_job" "glue-job" {
  name     = "airtable-${var.application_name}-${var.deployment_environment}"
  role_arn = aws_iam_role.application-role.arn

  command {
    script_location = "s3://${aws_s3_bucket.bucket_code.bucket}/example.py"
  }
}