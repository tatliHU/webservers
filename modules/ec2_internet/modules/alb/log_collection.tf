resource "aws_s3_bucket" "logs" {
  count         = var.log_collection ? 1 : 0
  bucket_prefix = "website-lb-logs-"
  force_destroy = true
  tags          = var.resource_tags
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "logs_role" {
  count = var.log_collection ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions = ["s3:PutObject"]
    resources = [
      aws_s3_bucket.logs[0].arn,
      "${aws_s3_bucket.logs[0].arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "log_collection" {
  count  = var.log_collection ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id
  policy = data.aws_iam_policy_document.logs_role[0].json
}