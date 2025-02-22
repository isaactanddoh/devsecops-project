# Secure CI/CD Infrastructure Project

A secure infrastructure-as-code project implementing best practices for AWS infrastructure deployment with multiple environments and comprehensive security controls.

## 🏗️ Architecture Overview

The infrastructure is organized into the following modules:

- **Networking**: VPC, Subnets, Security Groups
- **Security**: WAF, ACM, Security Policies
- **Load Balancer**: Application Load Balancer with HTTPS
- **Compute**: ECS Fargate with auto-scaling
- **Monitoring**: CloudWatch, Alerts, Logging

## 🔐 Security Features

- WAF protection for web applications
- HTTPS enforcement with modern TLS
- Container security controls
  - Non-root container user
  - Read-only root filesystem
  - Port restrictions (>1024)
- Network segmentation
- Access logging
- Encryption at rest and in transit
- Regular security scanning
- GuardDuty integration
- OPA policy enforcement

## 🛠️ Prerequisites

- AWS Account
- Terraform >= 1.0
- OPA (Open Policy Agent)
- GitHub Account (for CI/CD)
- AWS CLI configured
- Make utility
- Python 3.9+

## 📁 Directory Structure 
├── .github/
│ └── workflows/ # GitHub Actions workflows
├── infra/
│ ├── modules/ # Terraform modules
│ │ ├── 01networking/ # VPC and network configuration
│ │ ├── 02security/ # Security controls and WAF
│ │ ├── 03load-balancer/# ALB configuration
│ │ ├── 04compute/ # ECS and Lambda resources
│ │ └── 05monitoring/ # CloudWatch and alerting
│ ├── environments/ # Environment-specific configurations
│ ├── policies/ # IAM and OPA policies
│ └── tests/ # Terraform tests
└── README.md # Project documentation

## 🚀 Environment Configuration

The project supports three environments:

- **Dev**: Development environment
  - Minimal resources
  - Less strict security controls
  - Daily backups

- **Staging**: Pre-production environment
  - Moderate resources
  - Production-like security
  - Daily backups

- **Production**: Production environment
  - High availability
  - Strict security controls
  - Hourly backups

## 🔄 CI/CD Pipeline

The project includes two main GitHub Actions workflows:

1. **Terraform Validation Pipeline** (`terraform-ci.yml`)
   - Format checking
   - Terraform validation
   - OPA policy validation
   - Checkov security scanning

2. **Terraform Deployment Pipeline** (`terraform-cd.yml`)
   - Environment-specific deployments
   - Infrastructure changes
   - Slack notifications

## 📋 Usage

1. Clone the repository:

```bash
git clone https://github.com/isaactanddoh/devsecops-project.git
```

2. Initialize Terraform:
```bash
cd infra
terraform init
```

3. Select workspace:
```bash
terraform workspace select dev  # or staging/prod
```

4. Run OPA tests:
```bash
make test-opa
```

5. Plan and apply:
```bash
terraform plan -var-file="environments/terraform.tfvars.${workspace}"
terraform apply
```

## 🔍 Testing

- Run OPA policy tests:
```bash
make test-opa
```

- Run all tests:
```bash
make test-all
```

## 🔐 Security Considerations

- All sensitive data is encrypted at rest and in transit
- Secrets are managed through AWS SSM Parameter Store
- Regular security scans with Checkov
- WAF rules for common attack patterns
- Container security best practices enforced
- Network segmentation and least privilege access

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contact

- Owner: Isaac Tanddoh
- Project: Secure CI/CD Infrastructure
- Email: thekloudwiz@gmail.com

## 🙏 Acknowledgments

- JOMACS IT INC.
- HashiCorp Terraform
- Open Policy Agent
- AWS Well-Architected Framework
- DevSecOps Community
- GitHub Actions

## 📝 Notes

- This project is a work in progress and will be updated as we add more features and tests.
- Please feel free to contribute to the project.
- If you have any questions, please feel free to ask.
- Thank you for your interest in the project.