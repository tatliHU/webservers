data "aws_region" "current" {}
output "url" {
  value = format("https://%s.s3.%s.amazonaws.com/index.html", aws_s3_bucket.static_website.id, data.aws_region.current.name)
}
