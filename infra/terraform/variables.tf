# AWS region
variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

# Key pair for SSH access (optional if using SSM only)
variable "key_name" {
  type    = string
  default = "mtani-ssh"
}

# EC2 instance type
variable "instance_type" {
  type    = string
  default = "t3.small"
}

# App port
variable "app_port" {
  type    = number
  default = 8080
}

# VPC and Subnet will be discovered dynamically, leave defaults empty
variable "vpc_id" {
  type    = string
  default = ""  # fetched dynamically
}

variable "subnet_id" {
  type    = string
  default = ""  # fetched dynamically
}

# SSH access restricted to Jenkins master private IP
variable "allow_ssh_cidrs" {
  type    = list(string)
  default = ["172.31.27.67/32"] # Jenkins master private IP
}
