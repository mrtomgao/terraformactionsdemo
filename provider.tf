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

  default_tags {
    tags = {
        ApplicationId   = "value"
        Environment     = "value"
        Owner           = "value"
        CreatedBy       = "value"
        Classification  = "value"
        BusinessUnit    = "value"
        Project         = "value"
    }
  }
}
