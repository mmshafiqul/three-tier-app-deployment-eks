# 3-Tier Application Deployment with Terraform & Jenkins

A complete Infrastructure as Code (IaC) project demonstrating production-ready deployment of a 3-tier web application on AWS with automated SSL certificate generation, CI/CD pipeline, and comprehensive documentation.

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws)](https://aws.amazon.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins)](https://www.jenkins.io/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Quick Start](#quick-start)
- [Deployment Methods](#deployment-methods)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Documentation](#documentation)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Author](#author)

---

## 🎯 Overview

This project demonstrates a **complete DevOps workflow** from code to production, featuring:

- **3-tier architecture** deployed on AWS EC2 instances
- **Automated infrastructure provisioning** with Terraform modules
- **CI/CD pipeline** with Jenkins
- **Automated SSL certificate generation** using Let's Encrypt and Route53
- **Production-ready security** with VPC, private subnets, ALB, and security groups
- **Both automated and manual deployment options** for learning purposes

**Perfect for:**
- 🎓 DevOps students learning infrastructure automation
- 💼 Engineers wanting to understand complete deployment workflows
- 🏗️ Teams looking for Terraform module examples
- 📚 Anyone interested in AWS best practices

---

## 🏗️ Architecture

```
                           ┌─────────────────┐
                           │   End Users     │
                           └────────┬────────┘
                                    │ HTTPS
                           ┌────────▼────────┐
                           │    Route53      │
                           │  (DNS Service)  │
                           └────────┬────────┘
                                    │
              ┌─────────────────────▼─────────────────────┐
              │    Application Load Balancer (ALB)        │
              │    • SSL/TLS Termination                  │
              │    • Health Checks                        │
              │    • Public Subnets (Multi-AZ)            │
              └─────────────────────┬─────────────────────┘
                                    │
              ┌─────────────────────▼─────────────────────┐
              │   Frontend EC2 (Private Subnet)           │
              │   • Nginx Web Server                      │
              │   • React Application                     │
              │   • Let's Encrypt SSL                     │
              │   • Reverse Proxy to Backend              │
              └─────────────────────┬─────────────────────┘
                                    │ /api/*
              ┌─────────────────────▼─────────────────────┐
              │   Backend EC2 (Private Subnet)            │
              │   • Node.js + Express API                 │
              │   • PM2 Process Manager                   │
              │   • RESTful Endpoints                     │
              └─────────────────────┬─────────────────────┘
                                    │ PostgreSQL
              ┌─────────────────────▼─────────────────────┐
              │   Database EC2 (Private Subnet)           │
              │   • PostgreSQL Database                   │
              │   • Automated Migrations                  │
              │   • Remote Access Configured              │
              └───────────────────────────────────────────┘
```

### CI/CD Pipeline Flow

```
Developer → GitHub → Jenkins → Terraform → AWS Infrastructure → Production URL
    ↓          ↓         ↓          ↓              ↓                ↓
  Commit    Webhook   Pipeline   Provision      Deploy      https://domain.com
```

---

## ✨ Features

### 🚀 Infrastructure Automation
- ✅ **Terraform Modules** - Reusable, modular infrastructure code
- ✅ **Remote State Management** - S3 backend with state locking
- ✅ **Multi-Environment Support** - Easy environment separation
- ✅ **Automated Resource Tagging** - Cost tracking and organization

### 🔐 Security & Networking
- ✅ **VPC with Public/Private Subnets** - Network isolation
- ✅ **Security Groups** - Least-privilege access control
- ✅ **IAM Roles & Policies** - Secure AWS resource access
- ✅ **Automated SSL/TLS** - Let's Encrypt with Route53 DNS-01 challenge
- ✅ **HTTPS Redirect** - Automatic HTTP to HTTPS redirect

### 🏭 Application Deployment
- ✅ **3-Tier Architecture** - Separation of concerns
- ✅ **User Data Scripts** - Automated instance configuration
- ✅ **PM2 Process Manager** - Node.js application management
- ✅ **Database Migrations** - Automated schema setup
- ✅ **Health Checks** - ALB health monitoring

### 🔄 CI/CD Pipeline
- ✅ **Jenkins Integration** - Automated deployment pipeline
- ✅ **Approval Gates** - Manual approval for critical changes
- ✅ **Plan Before Apply** - Review infrastructure changes
- ✅ **Rollback Support** - Easy infrastructure rollback

### 📚 Documentation
- ✅ **Comprehensive READMEs** - Step-by-step guides
- ✅ **Inline Comments** - Well-documented code
- ✅ **Architecture Diagrams** - Visual representations
- ✅ **Troubleshooting Guides** - Common issues and solutions

---

## 💻 Technology Stack

### Application Layer
| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | React + Vite | Modern web UI framework |
| **Web Server** | Nginx | Reverse proxy and static file serving |
| **Backend** | Node.js + Express | RESTful API server |
| **Process Manager** | PM2 | Node.js application management |
| **Database** | PostgreSQL | Relational database |

### Infrastructure Layer
| Component | Technology | Purpose |
|-----------|------------|---------|
| **IaC** | Terraform | Infrastructure provisioning |
| **Cloud Provider** | AWS | Cloud infrastructure |
| **Compute** | EC2 | Virtual servers |
| **Load Balancer** | Application Load Balancer | Traffic distribution |
| **DNS** | Route53 | Domain name management |
| **SSL/TLS** | Let's Encrypt + Certbot | Certificate generation |
| **CI/CD** | Jenkins | Automated deployment pipeline |

### DevOps Tools
- **Git** - Version control
- **GitHub** - Code repository
- **AWS CLI** - AWS management
- **Bash** - Automation scripts

---

## 🚀 Quick Start

### Option 1: Automated Deployment with Terraform (Recommended)

```bash
# 1. Clone repository
git clone https://github.com/sarowar-alam/3-tier-app-terraform-jenkins.git
cd 3-tier-app-terraform-jenkins/terraform

# 2. Configure backend
cp backend-config.tfbackend.example backend-config.tfbackend
nano backend-config.tfbackend  # Update with your S3 bucket details

# 3. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Update with your AWS resources

# 4. Initialize Terraform
terraform init -backend-config=backend-config.tfbackend

# 5. Plan deployment
terraform plan -out=tfplan

# 6. Apply infrastructure
terraform apply tfplan

# 7. Get outputs
terraform output
```

**Deployment Time:** ~15 minutes  
**Result:** Production-ready application at `https://yourdomain.com`

### Option 2: CI/CD with Jenkins

```bash
# 1. Set up Jenkins with required plugins
# 2. Configure AWS credentials in Jenkins
# 3. Create new Pipeline job pointing to this repository
# 4. Run pipeline with parameters (plan/apply/destroy)
```

See [JENKINS.md](JENKINS.md) for detailed setup instructions.

### Option 3: Manual Deployment

For learning purposes or troubleshooting, follow the step-by-step manual deployment guide:

See [manual-implementation/README.md](manual-implementation/README.md)

---

## 🎯 Deployment Methods

This project supports **three deployment approaches**:

### 1. 🤖 Fully Automated (Terraform)
- **Best for:** Production deployments
- **Time:** ~15 minutes
- **Complexity:** Low
- **Documentation:** [terraform/README.md](terraform/README.md)

**Pros:**
- ✅ One-command deployment
- ✅ Infrastructure as Code
- ✅ Easy to replicate
- ✅ Version controlled

**Cons:**
- ❌ Requires AWS resources pre-created (VPC, subnets, security groups)
- ❌ Less visibility into process

### 2. 🔄 CI/CD Pipeline (Jenkins + Terraform)
- **Best for:** Team environments
- **Time:** ~15 minutes (after setup)
- **Complexity:** Medium
- **Documentation:** [JENKINS.md](JENKINS.md)

**Pros:**
- ✅ Automated on git push
- ✅ Approval gates for safety
- ✅ Audit trail
- ✅ Team collaboration

**Cons:**
- ❌ Requires Jenkins setup
- ❌ More initial configuration

### 3. 📖 Manual Step-by-Step
- **Best for:** Learning and understanding
- **Time:** ~30-45 minutes
- **Complexity:** High
- **Documentation:** [manual-implementation/README.md](manual-implementation/README.md)

**Pros:**
- ✅ Understand every step
- ✅ Great for learning
- ✅ Easy troubleshooting
- ✅ No Terraform required

**Cons:**
- ❌ Time-consuming
- ❌ Manual process
- ❌ Not repeatable

---

## 📁 Project Structure

```
3-tier-app-terraform-jenkins/
├── README.md                          # This file - Project overview
├── JENKINS.md                         # Jenkins pipeline documentation
├── Jenkinsfile                        # Jenkins pipeline definition
├── .gitignore                         # Git ignore rules
│
├── backend/                           # Node.js backend application
│   ├── src/
│   │   ├── server.js                 # Express server entry point
│   │   ├── routes.js                 # API routes
│   │   ├── db.js                     # Database connection
│   │   └── calculations.js           # Business logic
│   ├── migrations/                   # Database migrations
│   ├── package.json                  # Node.js dependencies
│   ├── ecosystem.config.js           # PM2 configuration
│   └── .env.example                  # Environment variables template
│
├── frontend/                          # React frontend application
│   ├── src/
│   │   ├── main.jsx                  # React entry point
│   │   ├── App.jsx                   # Main component
│   │   ├── api.js                    # API client
│   │   └── components/               # React components
│   ├── index.html                    # HTML template
│   ├── package.json                  # Node.js dependencies
│   ├── vite.config.js                # Vite configuration
│   └── .env.example                  # Environment variables template
│
├── database/                          # Database setup scripts
│   └── setup-database.sh             # PostgreSQL initialization
│
├── terraform/                         # Infrastructure as Code
│   ├── README.md                     # Terraform documentation
│   ├── main.tf                       # Root module
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values
│   ├── backend.tf                    # S3 backend configuration
│   ├── backend-config.tfbackend      # Backend config (gitignored)
│   ├── backend-config.tfbackend.example  # Backend config template
│   ├── terraform.tfvars              # Variable values (gitignored)
│   ├── terraform.tfvars.example      # Variables template
│   ├── deploy.sh                     # Deployment helper script
│   └── modules/                      # Terraform modules
│       ├── iam/                      # IAM roles and policies
│       ├── ec2/                      # EC2 instances
│       ├── alb/                      # Application Load Balancer
│       └── dns/                      # Route53 DNS records
│
└── manual-implementation/             # Manual deployment guides
    ├── README.md                     # Step-by-step manual guide
    ├── deploy-database.sh            # Database server setup
    ├── deploy-backend.sh             # Backend server setup
    └── deploy-frontend.sh            # Frontend server setup
```

---

## ✅ Prerequisites

### AWS Resources (Create Before Deployment)

1. **VPC with Subnets**
   - 1 VPC
   - 2 Public subnets (different AZs)
   - 2 Private subnets (different AZs)
   - Internet Gateway
   - NAT Gateway

2. **Security Groups**
   - ALB Security Group (HTTP/HTTPS from internet)
   - Frontend Security Group (HTTP from ALB)
   - Backend Security Group (Port 3000 from Frontend)
   - Database Security Group (Port 5432 from Backend)

3. **Route53 Hosted Zone**
   - Domain registered
   - Hosted zone created

4. **EC2 Key Pair**
   - SSH key pair for instance access

5. **S3 Bucket**
   - For Terraform state storage

### Local Tools

- **Terraform** >= 1.0
- **AWS CLI** configured with credentials
- **Git** for version control
- **Jenkins** (for CI/CD option)

### AWS Permissions

Your AWS credentials must have permissions for:
- EC2 (create, modify, delete instances)
- VPC (describe resources)
- Route53 (manage DNS records)
- IAM (create roles and policies)
- S3 (read/write state)
- ELB (create ALB and target groups)

---

## 📚 Documentation

Detailed documentation for each component:

| Document | Description |
|----------|-------------|
| [terraform/README.md](terraform/README.md) | Complete Terraform infrastructure guide |
| [JENKINS.md](JENKINS.md) | Jenkins pipeline setup and usage |
| [manual-implementation/README.md](manual-implementation/README.md) | Step-by-step manual deployment |

---

## 💡 Usage Examples

### Deploy to Production

```bash
cd terraform
terraform init -backend-config=backend-config.tfbackend
terraform plan -var-file=terraform.tfvars
terraform apply
```

### Update Application Code

```bash
# Update code in Git
git add .
git commit -m "Update application"
git push origin main

# Jenkins automatically deploys (if configured)
# Or manually re-apply Terraform
terraform apply -target=module.ec2
```

### View Infrastructure Outputs

```bash
terraform output
terraform output -json
terraform output application_url
```

### SSH to Instances

```bash
# Through bastion host
ssh -i your-key.pem ubuntu@bastion-ip
ssh ubuntu@private-instance-ip

# View logs
pm2 logs bmi-backend          # Backend logs
sudo tail -f /var/log/nginx/  # Frontend logs
sudo tail -f /var/log/postgresql/  # Database logs
```

### Destroy Infrastructure

```bash
terraform destroy -var-file=terraform.tfvars
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. **Terraform Init Fails**
```bash
# Solution: Check S3 bucket and AWS credentials
aws s3 ls s3://your-bucket-name
aws sts get-caller-identity
```

#### 2. **SSL Certificate Not Generated**
```bash
# Solution: Check IAM role and Route53 permissions
# SSH to frontend instance
sudo cat /var/log/letsencrypt/letsencrypt.log
```

#### 3. **Application Not Accessible**
```bash
# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <arn>

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>
```

#### 4. **Database Connection Failed**
```bash
# Test from backend server
nc -zv <database-private-ip> 5432
psql -h <database-ip> -U bmi_user -d bmi_db
```

For more troubleshooting, see individual documentation files.

---

## 🤝 Contributing

Contributions are welcome! This project is designed for learning, so improvements to documentation, code, or examples are appreciated.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m "Add: new feature"`)
6. Push to branch (`git push origin feature/improvement`)
7. Open a Pull Request

### Areas for Contribution

- 📝 Documentation improvements
- 🐛 Bug fixes
- ✨ New features
- 🧪 Test coverage
- 🎨 UI/UX improvements
- 🌍 Multi-region support
- 🔒 Security enhancements

---

## 📖 Learning Resources

This project covers:

- **Infrastructure as Code** - Terraform best practices
- **AWS Services** - EC2, VPC, ALB, Route53, IAM
- **CI/CD** - Jenkins pipeline automation
- **SSL/TLS** - Certificate automation with Let's Encrypt
- **3-Tier Architecture** - Application design patterns
- **DevOps Best Practices** - Security, monitoring, documentation

**Recommended Learning Path:**
1. Start with [manual-implementation](manual-implementation/README.md) to understand the basics
2. Move to [Terraform automation](terraform/README.md) to see IaC benefits
3. Implement [Jenkins pipeline](JENKINS.md) for full CI/CD

---

## 📊 Project Statistics

- **Infrastructure Components:** 15+ AWS resources
- **Lines of Terraform Code:** ~2,000+
- **Deployment Time:** 15 minutes (automated)
- **Modules:** 4 reusable Terraform modules
- **Documentation:** 4 comprehensive guides

---

## 🎓 Use Cases

### For Students
- Learn complete DevOps workflow
- Understand infrastructure automation
- Practice Terraform and AWS
- See real-world project structure

### For Professionals
- Reference architecture for 3-tier apps
- Terraform module examples
- Jenkins pipeline patterns
- SSL automation implementation

### For Teams
- Base template for new projects
- CI/CD pipeline starter
- Infrastructure standards
- Security best practices

---

## 🆘 Support

Having issues? Here's how to get help:

1. **Check Documentation** - Review the relevant README files
2. **Search Issues** - Look for similar problems in GitHub issues
3. **Review Logs** - Check application and infrastructure logs
4. **Create Issue** - Open a GitHub issue with details

**When reporting issues, include:**
- Error messages
- Terraform version
- AWS region
- Steps to reproduce

---

## 🔗 Quick Links

- 📦 **GitHub Repository:** https://github.com/sarowar-alam/3-tier-app-terraform-jenkins
- 📧 **Email:** sarowar@hotmail.com
- 💼 **LinkedIn:** [linkedin.com/in/sarowar](https://www.linkedin.com/in/sarowar/)
- 🌐 **Live Demo:** https://bmi.ostaddevops.click (if deployed)

---

## 🎯 Next Steps

After successful deployment:

1. ✅ Verify application is accessible
2. ✅ Test all API endpoints
3. ✅ Check SSL certificate validity
4. ✅ Review AWS CloudWatch logs
5. ✅ Set up monitoring and alerts
6. ✅ Configure backup strategy
7. ✅ Document any custom changes

---

## 🚀 Roadmap

Future enhancements planned:

- [ ] Auto Scaling Groups for high availability
- [ ] CloudWatch monitoring and alerting
- [ ] RDS instead of EC2 for database
- [ ] Multi-region deployment
- [ ] Blue-green deployment strategy
- [ ] Container-based deployment (ECS/EKS)
- [ ] Terraform Cloud integration
- [ ] GitHub Actions alternative to Jenkins

---

## 🧑‍💻 Author

**Md. Sarowar Alam**  
Lead DevOps Engineer, Hogarth Worldwide  
📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: [linkedin.com/in/sarowar](https://www.linkedin.com/in/sarowar/)

---

**⭐ If this project helped you, please star the repository!**

**🔄 Share with others learning DevOps!**

**💬 Feedback and suggestions are always welcome!**

---

*Built with ❤️ for the DevOps community*
