
# Project Name
variable "project_name" {
  description = "Project name"
  type        = string
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Subnet CIDR Blocks (Multi-AZ)
variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
  validation {
    condition     = length(var.subnet_cidrs) >= 2
    error_message = "At least 2 subnet CIDR blocks must be provided for high availability"
  }
}

#Allowed CIDR Blocks
variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for ALB access"
  type        = list(string)
}

# Availability Zones
variable "availability_zones_count" {
  description = "Number of AZs to use"
  type        = number
}

# Environment
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

# Container Port
variable "container_port" {
  description = "Port on which the container is listening"
  type        = number
}


