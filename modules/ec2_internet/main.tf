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
  name        = "allow_ssh_http_https"
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

# LoadBalancer
module "alb" {
  source = "./modules/alb"
  count  = var.replicas > 1 ? 1 : 0
  vpc_id                   = aws_vpc.internet_vpc.id
  subnet_ids               = [aws_subnet.internet_sn[0].id, aws_subnet.internet_sn[1].id]
  security_group_id        = aws_security_group.allow_ssh.id
  ec2_ids                  = aws_instance.internet_ec2[*].id
  log_collection           = var.log_collection
  resource_tags            = var.resource_tags
}