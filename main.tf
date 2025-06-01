module "vpc" {
  source          = "./modules/vpc"
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "security_groups" {
  source          = "./modules/security-groups"
  vpc_id          = module.vpc.vpc_id
  project_name = var.project_name
}

module "eks" {
  source = "./modules/eks"
  cluster_name    = "${var.project_name}-cluster"
  cluster_version = var.eks_cluster_version
  private_subnet_ids = module.vpc.private_subnet_ids
  desired_size = var.desired_size
  max_size     = var.max_size
  min_size     = var.min_size
  instance_types = ["t3.medium"]
  enable_public_endpoint = false
}

module "bastion" {
  source = "./modules/bastion"
  vpc_id          = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  project_name    = var.project_name
  public_key         = var.public_key
  bastion_sg_id     = module.security_groups.bastion_sg_id
}

module "ecr" {
  source = "./modules/ecr"
  repository_name = "${var.project_name}-repository"
  project_name    = var.project_name
}