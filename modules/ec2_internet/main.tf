terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "internet_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = var.resource_tags
}

resource "aws_subnet" "internet_sn" {
  for_each   = {0 = "10.0.0.0/17", 1 = "10.0.128.0/17"}
  vpc_id     = aws_vpc.internet_vpc.id
  cidr_block = each.value
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[each.key]
  tags = var.resource_tags
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.internet_vpc.id
  tags = var.resource_tags
}

resource "aws_route_table" "internet_route_table" {
  vpc_id = aws_vpc.internet_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = var.resource_tags
}

resource "aws_route_table_association" "internet_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.internet_sn[count.index].id
  route_table_id = aws_route_table.internet_route_table.id
}

resource "aws_key_pair" "internet_kp" {
  key_name   = "internet-key"
  public_key = var.public_key
  tags = var.resource_tags
}

resource "aws_instance" "internet_ec2" {
  count         = var.replicas
  ami           = var.ami
  instance_type = var.ec2_instance_type
  key_name = aws_key_pair.internet_kp.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.internet_sn[count.index%2].id
  tags = var.resource_tags
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.internet_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}

resource "aws_lb" "internet_load_balancer" {
  name               = "ec2-internet-loadbalancer"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.allow_ssh.id]
  subnets            = [aws_subnet.internet_sn[0].id, aws_subnet.internet_sn[1].id]

  #access_logs {
  #  bucket        = "foo"
  #  bucket_prefix = "bar"
  #  interval      = 60
  #}

  tags = var.resource_tags
}

resource "aws_lb_target_group" "ec2_target" {
  name     = "ec2-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.internet_vpc.id
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
  count            = var.replicas
  target_group_arn = aws_lb_target_group.ec2_target.arn
  target_id        = aws_instance.internet_ec2[count.index].id
  port             = 80
}