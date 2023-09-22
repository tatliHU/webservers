terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_lb" "internet_load_balancer" {
  name               = "ec2-internet-loadbalancer"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.logs[0].id
    enabled = var.log_collection
  }

  tags = var.resource_tags
}

resource "aws_lb_target_group" "ec2_target" {
  name     = "ec2-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "internet_lb_listener" {
  load_balancer_arn = aws_lb.internet_load_balancer.arn
  port              = "80"
  protocol          = "HTTP" 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_targets" {
  count            = length(var.ec2_ids)
  target_group_arn = aws_lb_target_group.ec2_target.arn
  target_id        = var.ec2_ids[count.index]
  port             = 80
}