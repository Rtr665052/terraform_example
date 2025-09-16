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
    Name = "new_vpc_2"
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pipeline_vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.pipeline_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "my_app" {
  ami           = "ami-0fe972392d04329e1" # Amazon Linux 2 in us-east-2 (example)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id

  tags = {
    Name = "my_app_server"
  }
}

output "app_dns" {
  value = aws_instance.my_app.public_dns
}