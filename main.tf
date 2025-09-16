terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# create VPC

resource "aws_vpc" "pipeline_vpc" {
  cidr_block = "192.168.0.0/20"
  tags = {
    Name = "new_vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.pipeline_vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "new_subnet"
  }
}