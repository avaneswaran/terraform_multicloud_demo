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

# Keep your existing AWS outputs unchanged, then replace the Azure outputs with:

# Azure outputs (updated to remove public IP references)
output "azure_vm_id" {
  description = "ID of the Azure VM"
  value       = azurerm_linux_virtual_machine.demo.id
}

output "azure_vm_private_ip" {
  description = "Private IP address of the Azure VM"
  value       = azurerm_linux_virtual_machine.demo.private_ip_address
}

output "azure_resource_group" {
  description = "Azure resource group name"
  value       = azurerm_resource_group.demo.name
}

output "multi_cloud_summary" {
  description = "Summary of multi-cloud deployment"
  value = {
    aws = {
      instance_id = aws_instance.demo.id
      public_ip   = aws_instance.demo.public_ip
      region      = var.aws_region
    }
    azure = {
      vm_id      = azurerm_linux_virtual_machine.demo.id
      private_ip = azurerm_linux_virtual_machine.demo.private_ip_address
      location   = var.azure_location
    }
  }
}

# Combined Ansible inventory output (updated)
output "ansible_inventory" {
  description = "Multi-cloud inventory for Ansible"
  value = <<-EOF
[aws_servers]
${aws_instance.demo.public_ip} ansible_user=ec2-user

[azure_servers]
${azurerm_linux_virtual_machine.demo.private_ip_address} ansible_user=${var.azure_admin_username}

[all_servers:children]
aws_servers
azure_servers

[all_servers:vars]
environment=${var.environment}
project=${var.project_name}
EOF
}