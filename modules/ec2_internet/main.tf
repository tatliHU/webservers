terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_vpc" "internet_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = var.resource_tags
}

resource "aws_subnet" "internet_sn" {
  vpc_id     = aws_vpc.internet_vpc.id
  cidr_block = "10.0.0.0/16"
  map_public_ip_on_launch = "true"
  tags = var.resource_tags
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.internet_vpc.id
  tags = var.resource_tags
}

resource "aws_route_table" "internet-route-table" {
  vpc_id = aws_vpc.internet_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = var.resource_tags
}

resource "aws_route_table_association" "internet_route_table_association" {
  subnet_id      = aws_subnet.internet_sn.id
  route_table_id = aws_route_table.internet-route-table.id
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
  subnet_id = aws_subnet.internet_sn.id
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
