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

resource "aws_instance" "my_app" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-2 (example)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id

  tags = {
    Name = "my_app_server"
  }
}

output "app_dns" {
  value = aws_instance.my_app.public_dns
}