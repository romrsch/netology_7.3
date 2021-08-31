provider "aws" {
        region = "us-west-2"
}

locals {
  web_instance_count_map = {
  stage = 1
  prod = 2
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "netology-bucket-${count.index}-${terraform.workspace}"
  acl    = "private"
  tags = {
    Name        = "Bucket ${count.index}"
    Environment = terraform.workspace
  }
  count = local.web_instance_count_map[terraform.workspace]
}

locals {
  backets_ids = toset([
    "e1",
    "e2",
  ])
}
resource "aws_s3_bucket" "bucket_e" {
  for_each = local.backets_ids
  bucket = "netology-bucket-${each.key}-${terraform.workspace}"
  acl    = "private"
  tags = {
    Name        = "Bucket ${each.key}"
    Environment = terraform.workspace
  }
}

