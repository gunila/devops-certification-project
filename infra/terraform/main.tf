# Generate a random suffix to avoid name conflicts
resource "random_id" "suffix" {
  byte_length = 2
}

# Find latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  selected_subnet_id = data.aws_subnets.default.ids[0]
}

# Security group for test server
resource "aws_security_group" "test_sg" {
  name        = "jenkins-test-sg-${random_id.suffix.hex}"
  description = "Allow SSH and app port"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allow_ssh_cidrs  # Jenkins master private IP
  }

  ingress {
    description = "App"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-test-sg-${random_id.suffix.hex}" }
}

# IAM role for SSM access
data "aws_iam_policy_document" "ssm_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_ec2_role" {
  name               = "jenkins-test-ssm-ec2-role-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "jenkins-test-ssm-profile-${random_id.suffix.hex}"
  role = aws_iam_role.ssm_ec2_role.name
}

# Cloud-init to prep the box
locals {
  user_data = <<-CLOUD
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io git jq
    systemctl enable docker
    systemctl start docker
    useradd -m -s /bin/bash jenkins || true
    usermod -aG docker jenkins
  CLOUD
}

# Test server EC2 instance
resource "aws_instance" "test_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.selected_subnet_id
  vpc_security_group_ids      = [aws_security_group.test_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  user_data                   = local.user_data
  associate_public_ip_address = true  # automatically gets public IP

  tags = {
    Name        = "jenkins-ephemeral-test-${random_id.suffix.hex}"
    Environment = "ci"
    Owner       = "Jenkins"
  }
}

# Optional: Terraform-managed Elastic IP
resource "aws_eip" "test_server_eip" {
  instance = aws_instance.test_server.id
  domain   = "vpc"
  tags = {
    Name = "jenkins-test-eip-${random_id.suffix.hex}"
  }
}
