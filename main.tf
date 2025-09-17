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

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.pipeline_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow anywhere for testing
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app_sg" }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.pipeline_vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
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
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  tags = {
    Name = "my_app_server"
  }
  
  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    yum update -y
    
    # Install Nginx
    amazon-linux-extras install nginx1 -y
    
    # Create Nginx config with security headers
    cat > /etc/nginx/conf.d/default.conf << EOL
    server {
        listen 80 default_server;

        location / {
            root /usr/share/nginx/html;
            index index.html;
            
            # Security headers
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self';" always;
            add_header Permissions-Policy "geolocation=(), microphone=()" always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        }
    }
    EOL

    # Start Nginx
    systemctl enable nginx
    systemctl start nginx
    EOF
}

output "app_dns" {
  value = aws_instance.my_app.public_ip
}