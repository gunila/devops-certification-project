# EC2 instance ID
output "test_instance_id" {
  value = aws_instance.test_server.id
}

# Private IP
output "test_private_ip" {
  value = aws_instance.test_server.private_ip
}

# Public IP (may be empty)
output "test_public_ip" {
  value       = aws_instance.test_server.public_ip
  description = "Will be empty if instance has no public IP"
}

# Terraform-managed Elastic IP
output "test_eip" {
  value       = aws_eip.test_server_eip.public_ip
  description = "Elastic IP assigned to test server (static public IP)"
}

# App URL using private IP
output "test_app_url" {
  value       = "http://${aws_instance.test_server.private_ip}:${var.app_port}"
  description = "Use private IP for access inside VPC"
}
