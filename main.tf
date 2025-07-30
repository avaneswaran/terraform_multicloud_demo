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

  ingress {
    description = "SSH from corporate network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
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

# Comprehensive tagging strategy
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
}