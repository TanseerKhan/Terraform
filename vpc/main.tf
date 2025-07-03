# AWS VPC
resource "aws_vpc" "prod-vpc" {
    cidr_block = var.cidr_block
    tags = {
      Name = "prod-vpc"
      Environment = "Production"
    }
}