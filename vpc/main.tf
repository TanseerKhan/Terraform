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

# Elastic IP for NAT Gateway
resource "aws_eip" "nat-eip" {
  count = length(var.private_subnet_cidrs)
}

# NAT Gateway
resource "aws_nat_gateway" "ngw" {
    count = length(var.private_subnet_cidrs)
    depends_on = [ aws_eip.nat-eip ] # Ensure EIP is created before NAT Gateway
    allocation_id = aws_eip.nat-eip[count.index].id
    subnet_id = aws_subnet.private_subnet[count.index].id
    tags = {
      Name = "ngw-${count.index + 1}"
      Environment = "production"
    }
}

# Route Table for Public Subnets
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.prod-vpc.id
  depends_on = [ aws_internet_gateway.igw ]
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
    Environment = "production"
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public-rt-assoc" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private-rt" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.prod-vpc.id
  depends_on = [ aws_nat_gateway.ngw ]
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }
  tags = {
    Name = "private-rt-${count.index + 1}"
    Environment = "production"
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private-rt-assoc" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private-rt[count.index].id
}
