project_name = "ITI-Grad-Project"

vpc_cidr     = "10.0.0.0/16"

region       = "us-east-1"

azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

eks_cluster_version = "1.28"

eks_node_instance_type = "t3.medium"

max_size = 6

min_size = 3

desired_size = 3

public_key = ""    # add the path to the public key here