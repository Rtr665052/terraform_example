# Terraform AWS DevSecOps Pipeline Example

This project demonstrates a **DevSecOps infrastructure deployment pipeline** using **Terraform, AWS CodeBuild/CodePipeline, Semgrep (SAST), and OWASP ZAP (DAST)**.

The pipeline automatically provisions AWS infrastructure, deploys a web server, and performs security scans against the deployed application.

This project demonstrates modern **Infrastructure as Code (IaC) and DevSecOps practices** used in cloud engineering environments.

---

# Overview

This repository contains Terraform configurations used to deploy AWS infrastructure and a CI/CD pipeline that performs security validation.

The pipeline performs the following actions:

1. Install Terraform
2. Run **Semgrep static security scans**
3. Initialize Terraform
4. Create AWS infrastructure
5. Deploy an EC2 web server
6. Wait for the application to respond
7. Run **OWASP ZAP dynamic security scanning**

This demonstrates a full **DevSecOps workflow** integrating infrastructure automation with automated security validation.

---

# Architecture

```
Developer Push
      │
      ▼
GitHub Repository
      │
      ▼
AWS CodeBuild / CodePipeline
      │
      ├── Pre-Build Stage
      │       Install Terraform
      │       Run Semgrep (SAST)
      │
      ├── Build Stage
      │       terraform init
      │       terraform plan
      │       terraform apply
      │
      ├── Application Deployment
      │       Launch EC2 Instance
      │       Install Nginx
      │       Configure security headers
      │
      └── Post-Build Security Testing
              Wait for application
              Run OWASP ZAP (DAST)
```

---

# Infrastructure Created

Terraform provisions the following AWS resources:

- VPC
- Public subnet
- Internet gateway
- Route table
- Security group
- EC2 instance
- Web server (Nginx)

The deployed EC2 instance runs **Nginx configured with multiple security headers**.

---

# Security Features

The deployed web server includes the following HTTP security headers:

- X-Frame-Options
- X-Content-Type-Options
- Content-Security-Policy
- Permissions-Policy
- X-XSS-Protection
- Referrer-Policy

These help mitigate common web vulnerabilities such as:

- clickjacking
- MIME sniffing
- cross-site scripting
- data leakage

---

# Repository Structure

```
terraform_example/
│
├── main.tf            # Terraform infrastructure definition
├── buildspec.yml      # CodeBuild pipeline configuration
├── Dockerfile         # Container configuration
└── README.md
```

---

# Terraform Infrastructure

The Terraform configuration creates:

### VPC
```
CIDR: 192.168.0.0/20
```

### Subnet
```
CIDR: 192.168.1.0/24
Availability Zone: us-east-2a
```

### Security Group

Allows:

```
HTTP (port 80)
from anywhere (0.0.0.0/0)
```

### EC2 Instance

Instance type:

```
t2.micro
```

The instance installs and runs **Nginx automatically using user_data**.

---

# CI/CD Pipeline (buildspec.yml)

The pipeline consists of three stages.

---

# Pre-Build Stage

Installs Terraform and runs **Semgrep security scans**.

```
terraform -version
pip install semgrep
semgrep --config=p/ci --error
```

Semgrep performs **static application security testing (SAST)**.

---

# Build Stage

Terraform deploys infrastructure.

```
terraform init
terraform plan
terraform apply
```

The pipeline captures the deployed server's public IP:

```
terraform output -raw app_dns
```

---

# Post-Build Stage

The pipeline waits for the application to become available and then runs **OWASP ZAP**.

```
docker run zaproxy/zap-stable
```

OWASP ZAP performs **dynamic application security testing (DAST)**.

---

# Technologies Used

## Infrastructure

- Terraform
- AWS

## AWS Services

- AWS VPC
- AWS EC2
- AWS Security Groups
- AWS CodeBuild / CodePipeline

## Security Tools

- Semgrep (SAST)
- OWASP ZAP (DAST)

## Web Server

- Nginx

---

# Prerequisites

To run this project locally you need:

- Terraform
- AWS CLI
- Docker
- Python

Configure AWS credentials:

```
aws configure
```

Verify authentication:

```
aws sts get-caller-identity
```

---

# Deployment

Clone the repository:

```
git clone https://github.com/Rtr665052/terraform_example.git
cd terraform_example
```

Initialize Terraform:

```
terraform init
```

Deploy infrastructure:

```
terraform apply
```

Once deployed, Terraform outputs the public IP of the application.

---

# Testing the Application

After deployment, open a browser and navigate to:

```
http://<EC2_PUBLIC_IP>
```

You should see the Nginx default page.

---

# DevSecOps Practices Demonstrated

This project demonstrates several modern DevSecOps principles:

- Infrastructure as Code
- automated infrastructure deployment
- static security scanning
- dynamic security scanning
- secure web server configuration
- automated cloud provisioning

---

# Future Improvements

Possible improvements include:

- adding TLS with AWS ACM
- implementing private subnets
- using an Application Load Balancer
- adding Terraform remote state
- integrating additional security tools
- adding automated rollback pipelines

---

# Learning Outcomes

This project demonstrates skills in:

- Terraform infrastructure automation
- AWS cloud architecture
- CI/CD pipeline integration
- DevSecOps security scanning
- automated infrastructure deployment

---

# License

Consider adding an open-source license such as:

MIT  
Apache 2.0
