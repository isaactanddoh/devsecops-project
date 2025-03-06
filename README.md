# Secure CI/CD Infrastructure Project

A secure infrastructure-as-code project implementing best practices for AWS infrastructure deployment with multiple environments and comprehensive security controls.

## 🌐 Deployed Applications

- **Portfolio Website**: [portfolio.thekloudwiz.com](https://portfolio.thekloudwiz.com)
- **Application Repository**: [Portfolio App](https://github.com/isaactanddoh/portfolio-app.git) - Modern portfolio application built with secure DevOps practices

## 🏗️ Architecture Overview

The infrastructure is organized into the following modules:

- **Networking**: VPC, Subnets, Security Groups
- **Security**: WAF, ACM, Security Policies
- **Load Balancer**: Application Load Balancer with HTTPS
- **Compute**: ECS Fargate with auto-scaling
- **Monitoring**: CloudWatch, Alerts, Logging

For detailed architecture information, see:
- Architecture Diagram: [`docs/architecture.png`](docs/architecture.png)

## 🔍 Security Monitoring & Incident Response

### Security Dashboard
The project includes two complementary dashboard systems:

1. **Infrastructure Monitoring Dashboard**
   - Resource utilization metrics
   - Performance monitoring
   - Cost tracking
   - Operational health

2. **Security Metrics Dashboard**
   - Vulnerability scanning results
   - AWS security findings
   - Container security metrics
   - Compliance status
   - Automated security alerts
   - Integration with:
     - Dependabot
     - Snyk
     - OWASP Dependency Check
     - GuardDuty
     - WAF

### Incident Response
The project includes a comprehensive incident response system:

1. **Incident Response Plan**
   - Response procedures
   - Team responsibilities
   - Communication protocols
   - Recovery steps

2. **Incident Reporting**
   - Standardized reporting template
   - Severity classification
   - Impact assessment
   - Response tracking
   - Evidence collection

3. **Response Automation**
   - GuardDuty-triggered Lambda functions
   - Automated WAF updates
   - Slack notifications
   - Email alerts

## 🔐 Security Features & SOC 2 Control Mappings

### Access Control & Authentication
- WAF protection for web applications (CC7.1, CC6.1)
- HTTPS enforcement with modern TLS (CC6.7)
- AWS IAM Identity Center integration (CC6.1, CC6.2)
- Role-based access control (CC6.3)
- Multi-factor authentication enforcement (CC6.1)

### Infrastructure Security
- Network segmentation with public/private subnets (CC6.6)
- Security group rules with least privilege (CC6.6, CC6.1)
- GuardDuty integration for threat detection (CC7.2, CC7.3)
- Encryption at rest and in transit (CC6.7, CC6.8)

### Container Security
- Non-root container user enforcement (CC6.1, CC6.8)
- Read-only root filesystem (CC6.8)
- Port restrictions (>1024) (CC6.6)
- Container image scanning (CC7.1)
- Resource limits and quotas (CC6.8)

### Monitoring & Logging
- CloudWatch metrics and alarms (CC3.1, CC7.2)
- Access logging for all components (CC7.2, CC4.1)
- VPC Flow Logs (CC4.1)
- AWS CloudTrail for API activity (CC4.1, CC7.2)
- Real-time security alerts (CC7.2, CC7.3)

### Vulnerability Management
- Automated vulnerability scanning (CC7.1, CC7.2)
  - Dependabot integration
  - OWASP dependency checks
  - Container image scanning
  - Infrastructure-as-code scanning
- Regular security assessments (CC7.1)
- Automated patching (CC7.1)

### Incident Response
- Standardized incident response process (CC7.3, CC7.4)
- Automated threat response (CC7.2, CC7.3)
  - GuardDuty findings trigger Lambda functions
  - WAF rule updates
  - Security group modifications
- Incident tracking and documentation (CC7.4)
- Post-incident analysis (CC7.4, CC7.5)

### Compliance & Governance
- OPA policy enforcement (CC6.8, CC7.1)
- Infrastructure-as-code security checks (CC7.1)
- Regular compliance scanning (CC4.1)
- Automated security reporting (CC2.3)

### Data Protection
- KMS encryption for sensitive data (CC6.7)
- S3 bucket security controls (CC6.6, CC6.7)
  - Versioning enabled
  - Encryption at rest
  - Public access blocked
- Backup and recovery procedures (A1.2)
- Data lifecycle management (CC6.7)

### Change Management
- Infrastructure-as-code version control (CC8.1)
- Automated deployment pipelines (CC8.1)
- Change approval workflows (CC8.1)
- Environment segregation (CC8.1)

### Business Continuity
- Multi-AZ deployment (A1.1)
- Automated backups (A1.2)
- Disaster recovery procedures (A1.2)
- High availability configuration (A1.1)

### SOC 2 Control Categories Addressed:
- CC2: Communication and Information
- CC3: Risk Assessment
- CC4: Monitoring Activities
- CC6: Logical and Physical Access Controls
- CC7: System Operations
- CC8: Change Management
- A1: Availability

## 🛠️ Prerequisites

- AWS Account
- Terraform >= 1.0
- OPA (Open Policy Agent)
- GitHub Account (for CI/CD)
- AWS CLI configured
- Make utility
- Python 3.9+

## 📁 Directory Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml      # CI workflow (format, validate, plan)
│       ├── terraform-cd.yml      # CD workflow (plan, apply)
│       └── terraform-destroy.yml # Destruction workflow
├── docs/
│   ├── screenshots/             # Infrastructure deployment snapshots
│   │   ├── networking/         # VPC, subnets, routing screenshots
│   │   ├── security/          # WAF, GuardDuty, Security Groups
│   │   ├── compute/          # ECS clusters and tasks
│   │   └── monitoring/       # CloudWatch dashboards and alerts
│   └── security/
│       ├── dashboard-config.yml    # Security dashboard configuration
│       ├── incident-scenario.md    # Security incident scenarios and playbooks
│       └── incident-response.md    # Incident response procedures
├── infra/
│   ├── modules/
│   │   ├── 01networking/        # VPC and network configuration
│   │   ├── 02security/         # Security controls and WAF
│   │   ├── 03load-balancer/    # ALB configuration
│   │   ├── 04compute/          # ECS and Lambda resources
│   │   └── 05monitoring/       # CloudWatch and alerting
│   ├── environments/
│   │   ├── terraform.tfvars.dev     # Dev environment variables
│   │   ├── terraform.tfvars.staging # Staging environment variables
│   │   └── terraform.tfvars.prod    # Production environment variables
│   ├── policies/               # IAM and security policies
│   ├── tests/                 # Infrastructure tests
│   ├── backend.tf             # Terraform backend configuration
│   ├── main.tf               # Main Terraform configuration
│   ├── outputs.tf            # Output definitions
│   ├── provider.tf           # Provider configuration
│   └── variables.tf          # Variable definitions
├── scripts/
│   └── security_dashboard.py  # Security metrics dashboard
└── README.md                 # Project documentation
```

## 📸 Infrastructure Documentation

### Deployment Screenshots
The `docs/screenshots` directory contains visual documentation of the deployed infrastructure:
- Network Architecture
- Security Controls
- ECS Deployments
- Monitoring Dashboards

### Security Documentation
The `docs/security` directory contains:
- **Dashboard Configuration** (`dashboard-config.yml`): Security metrics and alerts configuration
- **Incident Scenarios** (`incident-scenario.md`): Common security incident playbooks
- **Incident Response** (`incident-response.md`): Step-by-step incident response procedures

## 🚀 Environment Configuration

The project supports three environments:

- **Dev**: Development environment
  - Minimal resources
  - Less strict security controls
  - Configuration: `infra/environments/terraform.tfvars.dev`

- **Staging**: Pre-production environment
  - Moderate resources
  - Production-like security
  - Configuration: `infra/environments/terraform.tfvars.staging`

- **Production**: Production environment
  - High availability
  - Strict security controls
  - Configuration: `infra/environments/terraform.tfvars.prod`

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

## 📊 Monitoring & Alerting

### Infrastructure Monitoring
- CloudWatch metrics and alarms
- Auto-scaling metrics
- Performance monitoring
- Cost tracking
- Resource utilization

### Security Monitoring
- GuardDuty findings
- WAF metrics
- Login attempts
- Container vulnerabilities
- Dependency scanning
- Compliance status

### Security Dashboard Access
- Authentication required via AWS IAM Identity Center
- IP-based access restrictions
- HTTPS/TLS encryption enforced

### Alerting Channels
- Slack notifications
- Email alerts
- SNS topics
- CloudWatch alarms
- Security incident tickets

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