# main.tf - EC2 instance with enterprise tagging

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create security group
resource "aws_security_group" "demo_instance" {
  name_prefix = "${var.project_name}-${var.environment}-"
  description = "Security group for demo EC2 instance"
  vpc_id      = var.vpc_id

 # Add this ingress rule to your security group
ingress {
  description = "SSH from EC2 Instance Connect"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["18.232.65.104/29"]  # EC2 Instance Connect range for us-east-1
}

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-sg"
  })
}

# Create EC2 instance
resource "aws_instance" "demo" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.demo_instance.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
    
    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-root-volume"
    })
  }

  # Enable detailed monitoring for production
  monitoring = var.environment == "prod" ? true : false

  # Use IMDSv2 for enhanced security
  metadata_options {
    http_tokens = "required"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-instance"
  })
}

# ================================
# AZURE RESOURCES
# ================================

# Create Azure Resource Group
resource "azurerm_resource_group" "demo" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.azure_location

  tags = local.common_tags_azure
}

# Create Azure Virtual Network
resource "azurerm_virtual_network" "demo" {
  name                = "${var.project_name}-${var.environment}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  tags = local.common_tags_azure
}

# Create Azure Subnet
resource "azurerm_subnet" "demo" {
  name                 = "${var.project_name}-${var.environment}-subnet"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Create Azure Public IP
#resource "azurerm_public_ip" "demo" {
#  name                = "${var.project_name}-${var.environment}-pip"
#  resource_group_name = azurerm_resource_group.demo.name
#  location            = azurerm_resource_group.demo.location
#  allocation_method   = "Dynamic"
#
#  tags = local.common_tags_azure
#}

# Create Azure Network Security Group
resource "azurerm_network_security_group" "demo" {
  name                = "${var.project_name}-${var.environment}-nsg"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/8"  # Corporate network
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags_azure
}

# Create Azure Network Interface
resource "azurerm_network_interface" "demo" {
  name                = "${var.project_name}-${var.environment}-nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo.id
    private_ip_address_allocation = "Dynamic"
   # public_ip_address_id          = azurerm_public_ip.demo.id
  }

  tags = local.common_tags_azure
}

# Associate Network Security Group to Network Interface
resource "azurerm_network_interface_security_group_association" "demo" {
  network_interface_id      = azurerm_network_interface.demo.id
  network_security_group_id = azurerm_network_security_group.demo.id
}

# Create Azure Virtual Machine
resource "azurerm_linux_virtual_machine" "demo" {
  name                = "${var.project_name}-${var.environment}-vm"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  size                = var.azure_vm_size
  admin_username      = var.azure_admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.demo.id,
  ]

  admin_ssh_key {
    username   = var.azure_admin_username
    public_key = var.ssh_public_key_content
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags_azure

  # Ansible integration - same pattern as AWS
 # provisioner "local-exec" {
  #  command = <<-EOT
      # Wait for VM to be ready
   #   sleep 60
      
      # Add to Ansible inventory
   #   echo "Azure VM ${self.name} ready at ${azurerm_public_ip.demo.ip_address}"
   #   echo "Ready for Ansible configuration..."
      
      # Your existing Ansible playbooks would run here
      # ansible-playbook -i '${azurerm_public_ip.demo.ip_address},' your-playbook.yml
   # EOT
  #}
}

# Update your existing locals block to include Azure tags
locals {
  common_tags = {
    # Business tags for cost allocation
    Project      = var.project_name
    Environment  = var.environment
    CostCenter   = var.cost_center
    BusinessUnit = var.business_unit
    
    # Technical tags for operations
    ManagedBy         = "terraform"
    TerraformWorkspace = terraform.workspace
    
    # Compliance and governance
    DataClassification = var.data_classification
    Owner             = var.owner_email
    
    # Automation tags
    BackupSchedule     = var.backup_schedule
    PatchGroup        = "${var.environment}-linux"
    
    # Audit trail
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  # Azure-specific tags (same content but with Cloud identifier)
  common_tags_azure = merge(local.common_tags, {
    Cloud = "Azure"
  })
}