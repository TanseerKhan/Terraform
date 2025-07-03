# This file is used to configure the Terraform provider for AWS.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}