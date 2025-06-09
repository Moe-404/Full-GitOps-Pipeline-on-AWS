output "web_sg_id" {
value = aws_security_group.web_sg.id
}

output "bastion_sg_id" {
value = aws_security_group.bastion_sg.id
}

output "eks_worker_sg_id" {
  value = aws_security_group.eks_worker_sg.id
}
