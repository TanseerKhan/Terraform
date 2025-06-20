# Key-pair for EC2 instances

resource aws_key_pair "ec2_key_pair" {
    key_name = "ssh-keypair"
    public_key = file("./ssh-keypair.pub")
}

# VPC & Security Group 

resource aws_default_vpc default_vpc {

}

resource "aws_security_group" "ec2_security_group" {
    name        = "ec2_security_group"
    description = "Security group for EC2 instances"
    vpc_id      = aws_default_vpc.default_vpc.id

    tags = {
        Name = "ec2_security_group"
    }

    # Inbound rules
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH access"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP access"
    }

    # Outbound rules
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }
  
}

# EC2 Instance
resource "aws_instance" "ec2_instance" {
    key_name = aws_key_pair.ec2_key_pair.key_name
    security_groups = [aws_security_group.ec2_security_group.name]
    instance_type = "t2.micro"
    ami = "ami-0f918f7e67a3323f0" #ubuntu 24.04 LTS

    root_block_device {
        volume_size = 30
        volume_type = "gp3"
    }

    tags = {
      Name = "Terraform-EC2-Instance"
    }
    
}

