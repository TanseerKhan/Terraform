# AWS VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    tags = {
      Name = "prod-vpc"
      Environment = "Production"
    }
}