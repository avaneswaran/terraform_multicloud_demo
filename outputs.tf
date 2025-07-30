# outputs.tf - Output values for reference

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.demo.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.demo.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.demo.private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.demo_instance.id
}

output "instance_tags" {
  description = "Tags applied to the instance"
  value       = aws_instance.demo.tags
}