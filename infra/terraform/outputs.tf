# EC2 instance ID
output "test_instance_id" {
  value = aws_instance.test_server.id
}

# Private IP (used by Jenkins master)
output "test_private_ip" {
  value = aws_instance.test_server.private_ip
}

# Public IP (may be empty if instance has no public IP)
output "test_public_ip" {
  value       = aws_instance.test_server.public_ip
  description = "Will be empty if instance has no public IP"
}

# App URL using private IP (accessible only from VPC)
output "test_app_url" {
  value       = "http://${aws_instance.test_server.private_ip}:${var.app_port}"
  description = "Use private IP for access inside VPC"
}

# Elastic IP Public IP
output "test_server_eip_public_ip" {
  value       = aws_eip.test_server_eip.public_ip
  description = "Public IP of Test Server allocated via Elastic IP"
}

# App URL using Elastic IP
output "test_app_eip_url" {
  value       = "http://${aws_eip.test_server_eip.public_ip}:${var.app_port}"
  description = "App URL accessible via Elastic IP"
}
