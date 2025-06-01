resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_ids[0] # Create the bastion host in the first public subnet
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = var.public_key
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_cloudwatch_log_group" "bastion" {
  name = "/aws/bastion/${var.project_name}"
}
