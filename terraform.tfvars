# terraform.tfvars - Sample values for quick demo

# Infrastructure settings
aws_region      = "us-east-1"
vpc_id          = "vpc-f316c497"
subnet_id       = "subnet-530b3d0a"
key_pair_name   = "web1"
allowed_ssh_cidr = ["10.0.0.0/8", "192.168.1.0/24"]

# Business tags for cost allocation
project_name    = "customer-portal"
environment     = "dev"
cost_center     = "CC-4521"
business_unit   = "Digital Products"

# Governance tags
owner_email         = "devops-team@company.com"
data_classification = "internal"
backup_schedule     = "daily"

# Azure settings
azure_location        = "East US"
azure_vm_size        = "Standard_B1s"
azure_admin_username = "azureuser"
ssh_public_key_path  = "C:/Users/scud1/.ssh/id_rsa.pub"