# AWS region
variable "aws_region" {
  type    = string
  default = "eu-north-1"
  description = "AWS region to launch resources in"
}

# Key pair for SSH access (optional if using SSM only)
variable "key_name" {
  type        = string
  default     = "gunila-ssh"
  description = "Name of the EC2 Key Pair for SSH access"
}

# EC2 instance type
variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for test server"
}

# App port
variable "app_port" {
  type        = number
  default     = 8080
  description = "Port used by the application"
}

# VPC and Subnet will be discovered dynamically, leave defaults empty
variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID to deploy resources into; if empty, default VPC is used"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Subnet ID to deploy the EC2 instance; if empty, first default subnet is used"
}

# SSH access restricted to Jenkins master private IP
variable "allow_ssh_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs allowed to SSH into the test server (e.g., Jenkins master IP)"
}
