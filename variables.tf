# variables.tf - Input variables with enterprise defaults

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID for the instance"
  type        = string
  default     = "vpc-f316c497"
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["10.0.0.0/8"] # Corporate network
}

# Business tagging variables
variable "project_name" {
  description = "Project name for resource identification"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "business_unit" {
  description = "Business unit (Engineering, Sales, etc.)"
  type        = string
}

variable "owner_email" {
  description = "Owner email for accountability"
  type        = string
}

variable "data_classification" {
  description = "Data sensitivity level"
  type        = string
  default     = "internal"
}

variable "backup_schedule" {
  description = "Backup schedule for the instance"
  type        = string
  default     = "daily"
}

# Add these Azure variables to your existing variables.tf

# Azure configuration variables
variable "azure_location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "azure_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "azure_admin_username" {
  description = "Admin username for Azure VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for Azure VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_public_key_content" {
  description = "Content of SSH public key for Azure VM"
  type        = string
  default   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKGUGy1rwWgtOMepxvZH+rwBqUCayKFtVj8KezQpOsAG5SvM1MAznveVIwDNEUdneEV7uCsb/AhR74TNuhrFBRXabhgXDFgo5k7hyA2pKwjIy4pGYeTydTmF1tfwroS/qwQWwYFQaFqCSmfVruLNQCTxcsD1/9sSBDY9mo0WKuQg8Cc3b7TxcMIMNqZC6uRkBQamUSo3Eb3Cn3/aKIe95jOgd/g7OQbswyETZ/fDyFZptx8UVtId8zE5XozvodUJ3KOk+V9BxNtGU3LEj5hJpKqqqBeeMkCQhnO1xwU49BmB5rTD18Od9szyB3O/BUJkme5xcOxYoa8bjQEBd6efbVj5Gpa3TaIpEYL5cL6yKliwHO4MAkJis42dZ/QnWKIuKmAyhe+LkVS+i5flSevY3NZBgMqRZCFBcUMzcfbcip9l6yKydcCjA+aF0D9OQ06YjTc6W9R5qHc8HT2Adc7/39pp+Jq5uxc8y3JdxJw45kZnkQAcqIYWFbR+Nyg6HaoEpiIQxvol5To3QBJyAPPtFP/K7+exbU2M2H9FPwLW0f8JcDnwyYr+NaKhyYHAQG2h5mstVbsOYK8rkGDPTqcQKLAnaDWVz5yBrL/gknb27IFTvtNJ9xIa0mLx+EXuU7peTqGLYJeJ4d3T5w+yIzLJeujXZGkrHH3mLDUYf6bfzk9w== scud1@DESKTOP-093MM5O"
}

# Keep all your existing AWS variables unchanged...