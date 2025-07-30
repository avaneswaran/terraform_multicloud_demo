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