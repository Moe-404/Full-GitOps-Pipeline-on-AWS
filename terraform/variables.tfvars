region       = "us-east-1"
account_id   = "972016405773"

project_name = "grad-proj"

vpc_cidr = "10.0.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24"
]

eks_cluster_version = "1.32"

eks_node_instance_type = ["t3.medium"]


desired_size = 1
max_size     = 3
min_size     = 1

public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgkwQXYtuviOWoMMxd4on4OauqeYqqseWCqgk+5cBxB shahdfayez@shahdfayez-Ubunto"
