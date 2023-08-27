terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# NETWORKING
resource "aws_vpc" "eks_cluster" {
  cidr_block = "10.0.0.0/16"
  tags = var.resource_tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "eks_subnet" {
  for_each   = {0 = "10.0.0.0/17", 1 = "10.0.128.0/17"}
  vpc_id     = aws_vpc.eks_cluster.id
  cidr_block = each.value
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[each.key]
  tags = var.resource_tags
}

resource "aws_security_group" "eks_cluster" {
  name        = "eks_cluster"
  vpc_id      = aws_vpc.eks_cluster.id
  egress {                   # Outbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {                  # Inbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.resource_tags
}

resource "aws_internet_gateway" "worker_gw" {
  vpc_id = aws_vpc.eks_cluster.id
  tags = var.resource_tags
}

resource "aws_route_table" "worker_vpc_router" {
  vpc_id = aws_vpc.eks_cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.worker_gw.id
  }
  tags = var.resource_tags
}

resource "aws_route_table_association" "worker_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.eks_subnet[count.index].id
  route_table_id = aws_route_table.worker_vpc_router.id
}

# CLUSTER
resource "aws_iam_role" "eks_cluster" {
  name = "terraform_eks_cluster"
  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "eks.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
  tags = var.resource_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn =  aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version
  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = [for x in aws_subnet.eks_subnet: x.id]
  }
  depends_on = [ aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy ]
  tags = var.resource_tags
}

# WORKER NODES
resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group"
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "node_group1"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [for x in aws_subnet.eks_subnet: x.id]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t3.micro"]
}

# SET KUBECONFIG
data "aws_region" "current" {}
resource "null_resource" "update_kubectl" {
    depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.node]
    provisioner "local-exec" {
        command = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${var.cluster_name}"
    }
}