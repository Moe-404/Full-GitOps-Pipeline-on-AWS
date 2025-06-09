# EKS Cluster
# EKS cluster and node groups' security group and network interfaces get auto created, so we don't need to define them here.
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_endpoint
    security_group_ids = var.security_group_ids
  }
}

resource "aws_launch_template" "eks_lt" {
  name_prefix   = "${var.cluster_name}-lt"
  image_id      = data.aws_ami.eks_ami.id
  instance_type = var.instance_types[0]
  key_name      = var.key_pair_name

  vpc_security_group_ids = [var.eks_worker_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-worker"
    }
  }
}

data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# OIDC Provider for EKS
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  launch_template {
    id      = aws_launch_template.eks_lt.id
    version = "$Latest"
  }

  # Ensure worker nodes can connect to cluster
  remote_access {
    ec2_ssh_key = var.key_pair_name
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [scaling_config[0].desired_size]
  }
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.cluster.name
}