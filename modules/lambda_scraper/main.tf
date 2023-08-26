terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Role to run lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Role for log collection
resource "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "lambda_basic"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [aws_iam_policy.AWSLambdaBasicExecutionRole.arn]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/scraper.py"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "scraper" {
  filename      = "${path.module}/lambda_function_payload.zip"
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn

  handler = "${var.function_name}.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "python3.7"
  
  environment {
    variables = {
      url = var.url
    }
  }
  tags = var.resource_tags
}

# hook to recreate lambda invocation at every upgrade
resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

resource "aws_lambda_invocation" "start" {
  function_name = aws_lambda_function.scraper.function_name
  input = jsonencode({})
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}
