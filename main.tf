terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"


}

provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

resource "aws_s3_bucket" "toms-tf-demo-bucket-raw" {
  bucket = "toms-tf-demo-bucket-raw"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Toms TF Bucket for Raw"
    Environment = "QA"
  }
}

resource "aws_iam_role" "toms-tf-demo-role" {
  name = "toms-tf-demo-role"
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

resource "aws_glue_catalog_database" "toms-tf-demo-cat-db" {
  name = "toms-tf-demo-cat-db"
}

resource "aws_glue_crawler" "toms-tf-demo-crawler" {
  database_name = aws_glue_catalog_database.toms-tf-demo-cat-db.name
  name          = "toms-tf-demo-crawler"
  role          = aws_iam_role.toms-tf-demo-role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.toms-tf-demo-bucket-raw.bucket}"
  }
}