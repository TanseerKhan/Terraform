# AWS VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    tags = {
      Name = "prod-vpc"
      Environment = "production"
    }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = element(var.availability_zones, count.index)
    tags = {
      Name = "public-subnet-${count.index + 1}"
      Environment = "production"
    }
  
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = element(var.availability_zones, count.index)
    tags = {
      Name = "private-subnet-${count.index + 1}"
      Environment = "production"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod-igw"
    Environment = "production"
  }
}