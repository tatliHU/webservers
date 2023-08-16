terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_s3_bucket" "static_website" {
  bucket_prefix = "static-website"
  force_destroy = true
  tags = var.resource_tags
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "static_website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_website,
    aws_s3_bucket_public_access_block.static_website,
  ]
  bucket = aws_s3_bucket.static_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

locals {
  resource_file_dir = length(var.root_dir) > 0 ? var.root_dir : "${path.module}/resources"
}

resource "aws_s3_object" "file_upload" {
  for_each = fileset("${local.resource_file_dir}/", "*.*")
  bucket   = aws_s3_bucket.static_website.id
  key      = each.value
  source   = "${local.resource_file_dir}/${each.value}"
  acl      = "public-read"
}