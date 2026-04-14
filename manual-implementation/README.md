# BMI Health Tracker - Manual Deployment Guide

This guide walks you through manually deploying the BMI Health Tracker application on AWS EC2 instances without using Terraform. This is useful for learning, troubleshooting, or when automated infrastructure isn't available.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Step-by-Step Deployment](#step-by-step-deployment)
  - [1. Prepare AWS Infrastructure](#1-prepare-aws-infrastructure)
  - [2. Deploy Database Server](#2-deploy-database-server)
  - [3. Deploy Backend Server](#3-deploy-backend-server)
  - [4. Deploy Frontend Server](#4-deploy-frontend-server)
  - [5. Setup Load Balancer](#5-setup-load-balancer)
  - [6. Configure DNS](#6-configure-dns)
  - [7. Setup SSL Certificate](#7-setup-ssl-certificate)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

---

## 📖 Overview

The BMI Health Tracker is a 3-tier web application:

- **Frontend**: React + Vite (served by Nginx)
- **Backend**: Node.js + Express API
- **Database**: PostgreSQL

This guide deploys each tier on separate EC2 instances for a production-ready architecture.

---

## ✅ Prerequisites

### AWS Account Requirements

- AWS Account with appropriate permissions
- AWS CLI configured with your credentials
- EC2 Key Pair created in your target region

### Local Tools

- SSH client (for connecting to EC2 instances)
- AWS CLI (optional, for checking resources)
- Text editor

### Knowledge Requirements

- Basic Linux command line
- SSH and SCP file transfer
- AWS EC2 and VPC concepts

---

## 🏗️ Architecture

```
                                    ┌─────────────────┐
                                    │  Internet       │
                                    │  Users          │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │  Route53        │
                                    │  (DNS)          │
                                    └────────┬────────┘
                                             │
                        ┌────────────────────▼────────────────────┐
                        │  Application Load Balancer (ALB)        │
                        │  - SSL/TLS Termination                  │
                        │  - Health Checks                         │
                        │  Public Subnets (AZ1 + AZ2)             │
                        └────────────────────┬────────────────────┘
                                             │
                        ┌────────────────────▼────────────────────┐
                        │  Frontend EC2 (Private Subnet)          │
                        │  - Nginx Web Server                     │
                        │  - React App (static files)              │
                        │  - Port 80                               │
                        └────────────────────┬────────────────────┘
                                             │ /api/*
                        ┌────────────────────▼────────────────────┐
                        │  Backend EC2 (Private Subnet)            │
                        │  - Node.js + Express                     │
                        │  - PM2 Process Manager                   │
                        │  - Port 3000                             │
                        └────────────────────┬────────────────────┘
                                             │
                        ┌────────────────────▼────────────────────┐
                        │  Database EC2 (Private Subnet)           │
                        │  - PostgreSQL 14/15/16                   │
                        │  - Port 5432                             │
                        └─────────────────────────────────────────┘
```

---

## 🚀 Step-by-Step Deployment

### 1. Prepare AWS Infrastructure

#### 1.1 Create VPC (if you don't have one)

1. Go to **VPC Console** → **Create VPC**
2. Choose "VPC and more"
3. Configure:
   - **Name**: `bmi-vpc`
   - **IPv4 CIDR**: `10.0.0.0/16`
   - **Availability Zones**: 2
   - **Public subnets**: 2
   - **Private subnets**: 2
   - **NAT gateways**: 1 per AZ (or 1 for cost saving)
   - **VPC endpoints**: None

#### 1.2 Create Security Groups

Create the following security groups in your VPC:

**A. ALB Security Group** (`alb-sg`)
```
Inbound Rules:
- Type: HTTP, Port: 80, Source: 0.0.0.0/0
- Type: HTTPS, Port: 443, Source: 0.0.0.0/0
```

**B. Frontend Security Group** (`frontend-sg`)
```
Inbound Rules:
- Type: HTTP, Port: 80, Source: [ALB-SG-ID]
- Type: SSH, Port: 22, Source: [Your IP or Bastion]
```

**C. Backend Security Group** (`backend-sg`)
```
Inbound Rules:
- Type: Custom TCP, Port: 3000, Source: [Frontend-SG-ID]
- Type: SSH, Port: 22, Source: [Your IP or Bastion]
```

**D. Database Security Group** (`database-sg`)
```
Inbound Rules:
- Type: PostgreSQL, Port: 5432, Source: [Backend-SG-ID]
- Type: SSH, Port: 22, Source: [Your IP or Bastion]
```

#### 1.3 Note Your Resource IDs

Save these IDs for later:
```
VPC ID: vpc-xxxxxxxxxxxxxxxxx
Public Subnet 1 ID: subnet-xxxxxxxxxxxxxxxxx
Public Subnet 2 ID: subnet-yyyyyyyyyyyyyyyyy
Private Subnet 1 ID: subnet-zzzzzzzzzzzzzzzzz
Private Subnet 2 ID: subnet-aaaaaaaaaaaaaaaaa
ALB SG ID: sg-xxxxxxxxxxxxxxxxx
Frontend SG ID: sg-yyyyyyyyyyyyyyyyy
Backend SG ID: sg-zzzzzzzzzzzzzzzzz
Database SG ID: sg-aaaaaaaaaaaaaaaaa
```

---

### 2. Deploy Database Server

#### 2.1 Launch EC2 Instance

1. **Go to EC2 Console** → Launch Instance
2. **Configure**:
   - **Name**: `bmi-database`
   - **AMI**: Ubuntu Server 22.04 LTS (or 24.04)
   - **Instance type**: `t3.small` (2 vCPU, 2 GB RAM)
   - **Key pair**: Select your existing key pair
   - **Network**: Your VPC
   - **Subnet**: Private subnet 1
   - **Security group**: `database-sg`
   - **Storage**: 20 GB gp3
3. **Launch Instance**

#### 2.2 Connect to Database Server

Connect via SSH through a bastion host or Session Manager:

```bash
ssh -i your-key.pem ubuntu@<BASTION-IP>
ssh ubuntu@<DATABASE-PRIVATE-IP>
```

Or use AWS Systems Manager Session Manager (if configured).

#### 2.3 Upload and Run Deployment Script

**Option A: Direct Upload**
```bash
# On your local machine
scp -i your-key.pem deploy-database.sh ubuntu@<BASTION-IP>:~/
ssh -i your-key.pem ubuntu@<BASTION-IP>
scp deploy-database.sh ubuntu@<DATABASE-PRIVATE-IP>:~/
```

**Option B: Use Git**
```bash
# On database server
git clone https://github.com/your-username/terraform-3-tier-different-servers.git
cd terraform-3-tier-different-servers/manual-implementation
```

#### 2.4 Configure and Run

Edit the script to set your values:
```bash
nano deploy-database.sh
```

Update these variables at the top:
```bash
DB_NAME="bmi_db"
DB_USER="bmi_user"
DB_PASSWORD="your-strong-password-here"  # CHANGE THIS!
DB_PORT="5432"
```

Run the script:
```bash
chmod +x deploy-database.sh
sudo ./deploy-database.sh
```

#### 2.5 Save Database Connection Info

The script will output:
```
Database Details:
  Host: 10.0.1.10
  Port: 5432
  Database: bmi_db
  User: bmi_user
  Password: your-password
```

**Save these details!** You'll need them for the backend server.

#### 2.6 Verify Database

```bash
# Test connection
psql -h localhost -U bmi_user -d bmi_db

# Inside psql
\dt          # List tables (should show measurements table)
\q           # Quit
```

---

### 3. Deploy Backend Server

#### 3.1 Launch EC2 Instance

1. **EC2 Console** → Launch Instance
2. **Configure**:
   - **Name**: `bmi-backend`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: `t3.small` (2 vCPU, 2 GB RAM)
   - **Key pair**: Your key pair
   - **Network**: Your VPC
   - **Subnet**: Private subnet 1 or 2
   - **Security group**: `backend-sg`
   - **Storage**: 15 GB gp3
3. **Launch Instance**

#### 3.2 Connect to Backend Server

```bash
ssh -i your-key.pem ubuntu@<BASTION-IP>
ssh ubuntu@<BACKEND-PRIVATE-IP>
```

#### 3.3 Upload and Configure Deployment Script

```bash
# Upload script (from local or clone repo)
git clone https://github.com/sarowar-alam/3-tier-app-terraform-jenkins.git
cd 3-tier-app-terraform-jenkins/manual-implementation
```

Edit the script:
```bash
nano deploy-backend.sh
```

Update these variables:
```bash
DB_HOST="10.0.1.10"              # Database private IP from step 2.5
DB_PORT="5432"
DB_NAME="bmi_db"
DB_USER="bmi_user"
DB_PASSWORD="your-strong-password-here"  # Same as database
BACKEND_PORT="3000"
FRONTEND_URL="https://bmi.example.com"   # Your domain
```

#### 3.4 Run Deployment

```bash
chmod +x deploy-backend.sh
sudo ./deploy-backend.sh
```

#### 3.5 Verify Backend

```bash
# Check PM2 status
pm2 status

# Check logs
pm2 logs bmi-backend

# Test health endpoint
curl http://localhost:3000/health

# Test API
curl http://localhost:3000/api/measurements
```

#### 3.6 Save Backend Connection Info

Note the backend private IP:
```
Backend Details:
  Host: 10.0.2.15
  Port: 3000
```

---

### 4. Deploy Frontend Server

#### 4.1 Launch EC2 Instance

1. **EC2 Console** → Launch Instance
2. **Configure**:
   - **Name**: `bmi-frontend`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: `t3.small` (2 vCPU, 2 GB RAM)
   - **Key pair**: Your key pair
   - **Network**: Your VPC
   - **Subnet**: Private subnet 1 or 2
   - **Security group**: `frontend-sg`
   - **Storage**: 15 GB gp3
3. **Launch Instance**

#### 4.2 Connect to Frontend Server

```bash
ssh -i your-key.pem ubuntu@<BASTION-IP>
ssh ubuntu@<FRONTEND-PRIVATE-IP>
```

#### 4.3 Upload and Configure Deployment Script

```bash
# Clone repository
git clone https://github.com/sarowar-alam/3-tier-app-terraform-jenkins.git
cd 3-tier-app-terraform-jenkins/manual-implementation
```

Edit the script:
```bash
nano deploy-frontend.sh
```

Update these variables:
```bash
BACKEND_HOST="10.0.2.15"        # Backend private IP from step 3.6
BACKEND_PORT="3000"
DOMAIN="bmi.example.com"        # Your domain name
```

#### 4.4 Run Deployment

```bash
chmod +x deploy-frontend.sh
sudo ./deploy-frontend.sh
```

#### 4.5 Verify Frontend

```bash
# Check Nginx status
sudo systemctl status nginx

# Test frontend locally
curl http://localhost/

# Check Nginx logs
sudo tail -f /var/log/nginx/bmi-access.log
```

---

### 5. Setup Load Balancer

#### 5.1 Create Target Group

1. **EC2 Console** → **Target Groups** → **Create target group**
2. **Configure**:
   - **Target type**: Instances
   - **Name**: `bmi-frontend-tg`
   - **Protocol**: HTTP
   - **Port**: 80
   - **VPC**: Your VPC
   - **Health check**:
     - Path: `/health`
     - Healthy threshold: 2
     - Interval: 30 seconds
3. **Register targets**: Select frontend EC2 instance
4. **Create target group**

#### 5.2 Create Application Load Balancer

1. **EC2 Console** → **Load Balancers** → **Create load balancer**
2. Choose **Application Load Balancer**
3. **Configure**:
   - **Name**: `bmi-alb`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4
   - **VPC**: Your VPC
   - **Mappings**: Select both public subnets
   - **Security groups**: Select `alb-sg`
4. **Listeners**:
   - **HTTP (80)**: Forward to `bmi-frontend-tg`
5. **Create load balancer**

#### 5.3 Get ALB DNS Name

After creation, copy the ALB DNS name:
```
DNS name: bmi-alb-1234567890.ap-south-1.elb.amazonaws.com
```

Test it:
```bash
curl http://bmi-alb-1234567890.ap-south-1.elb.amazonaws.com
```

---

### 6. Configure DNS

#### 6.1 Create Route53 Record

1. **Route53 Console** → **Hosted zones** → Your domain
2. **Create record**:
   - **Record name**: `bmi` (or leave empty for root domain)
   - **Record type**: A
   - **Alias**: Yes
   - **Route traffic to**: 
     - Application and Classic Load Balancer
     - Your region
     - Select your ALB
3. **Create record**

#### 6.2 Verify DNS

```bash
# Wait 1-2 minutes, then test
nslookup bmi.example.com

# Test HTTP access
curl http://bmi.example.com
```

---

### 7. Setup SSL Certificate

#### 7.1 Request Certificate (ACM)

1. **AWS Certificate Manager** → **Request certificate**
2. Choose **Request a public certificate**
3. **Domain names**: 
   - `bmi.example.com`
   - `*.example.com` (optional, for wildcard)
4. **Validation method**: DNS validation
5. **Request certificate**

#### 7.2 Validate Certificate

1. Click **Create records in Route53** (easier)
   - Or manually add CNAME records to Route53
2. Wait 5-30 minutes for validation

#### 7.3 Add HTTPS Listener to ALB

1. **EC2 Console** → **Load Balancers** → Select your ALB
2. **Listeners** tab → **Add listener**
3. **Configure**:
   - **Protocol**: HTTPS
   - **Port**: 443
   - **Default actions**: Forward to `bmi-frontend-tg`
   - **Security policy**: `ELBSecurityPolicy-TLS13-1-2-2021-06` (recommended)
   - **Certificate**: Select your ACM certificate
4. **Save**

#### 7.4 Redirect HTTP to HTTPS

1. Edit the **HTTP:80 listener**
2. Change action to **Redirect to HTTPS**:
   - Protocol: HTTPS
   - Port: 443
   - Status code: 301 (Permanent redirect)
3. **Save**

#### 7.5 Test HTTPS

```bash
# Test HTTPS
curl https://bmi.example.com

# Should redirect
curl -I http://bmi.example.com
```

---

## ✅ Verification

### Full Application Test

1. **Open browser**: `https://bmi.example.com`
2. **Enter BMI data**:
   - Height: 170 cm
   - Weight: 70 kg
3. **Click Calculate**
4. **Verify**:
   - BMI shows correctly
   - Category displays
   - Chart appears
   - Data persists on refresh

### Component Health Checks

```bash
# Database
ssh ubuntu@<DATABASE-IP>
sudo -u postgres psql -d bmi_db -c "SELECT COUNT(*) FROM measurements;"

# Backend
ssh ubuntu@<BACKEND-IP>
pm2 status
pm2 logs bmi-backend --lines 50

# Frontend
ssh ubuntu@<FRONTEND-IP>
sudo systemctl status nginx
sudo tail -f /var/log/nginx/bmi-access.log

# ALB
# Check target health in AWS Console
# EC2 → Target Groups → bmi-frontend-tg → Targets tab
```

---

## 🔧 Troubleshooting

### Issue: Database Connection Failed

**Symptoms**: Backend can't connect to database

**Check**:
```bash
# On backend server
telnet <DATABASE-PRIVATE-IP> 5432
# Or
nc -zv <DATABASE-PRIVATE-IP> 5432
```

**Solutions**:
1. Verify security group allows backend SG → database SG on port 5432
2. Check PostgreSQL config allows remote connections
3. Verify database credentials in backend `.env` file

### Issue: Backend Not Responding

**Check**:
```bash
# On backend server
pm2 status
pm2 logs bmi-backend --lines 100

# Check if process is running
sudo lsof -i :3000
```

**Solutions**:
1. Restart PM2: `pm2 restart bmi-backend`
2. Check database connection
3. Review environment variables in `.env`

### Issue: Frontend Shows 502 Bad Gateway

**Check**:
```bash
# On frontend server
sudo systemctl status nginx
sudo nginx -t
curl http://localhost/

# Test backend connection
curl http://<BACKEND-IP>:3000/health
```

**Solutions**:
1. Verify Nginx config has correct backend IP
2. Check backend security group allows frontend traffic
3. Restart Nginx: `sudo systemctl restart nginx`

### Issue: ALB Target Unhealthy

**Check**:
1. AWS Console → Target Groups → Health checks
2. Verify `/health` endpoint exists and returns 200
3. Check security group allows ALB → frontend on port 80

**Solutions**:
1. Fix health check endpoint
2. Update security groups
3. Check frontend server firewall

### Issue: SSL Certificate Not Working

**Check**:
1. Certificate status in ACM (must be "Issued")
2. ALB listener has certificate attached
3. DNS CNAME records created for validation

**Solutions**:
1. Wait for certificate validation (can take 30 minutes)
2. Recreate DNS validation records
3. Ensure domain is pointed to ALB

---

## 🔄 Maintenance

### Update Application Code

**Backend**:
```bash
ssh ubuntu@<BACKEND-IP>
cd ~/app
git pull origin main
cd backend
npm install
pm2 restart bmi-backend
```

**Frontend**:
```bash
ssh ubuntu@<FRONTEND-IP>
cd ~/app
git pull origin main
cd frontend
npm install
npm run build
sudo cp -r dist/* /var/www/bmi.example.com/
```

### View Logs

```bash
# Backend
pm2 logs bmi-backend

# Frontend
sudo tail -f /var/log/nginx/bmi-access.log
sudo tail -f /var/log/nginx/bmi-error.log

# Database
sudo tail -f /var/log/postgresql/postgresql-<version>-main.log
```

### Backup Database

```bash
# On database server
sudo -u postgres pg_dump bmi_db > bmi_backup_$(date +%Y%m%d).sql

# Download backup
scp ubuntu@<DATABASE-IP>:~/bmi_backup_*.sql ./
```

### Restore Database

```bash
# On database server
sudo -u postgres psql bmi_db < bmi_backup_20260123.sql
```

### Monitor Resources

```bash
# CPU, Memory, Disk
htop
df -h
free -h

# Nginx connections
sudo netstat -antp | grep nginx

# PostgreSQL connections
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"
```

### Security Updates

```bash
# All servers
sudo apt update
sudo apt upgrade -y
sudo reboot  # If kernel updated
```

---

## 📚 Additional Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [PM2 Documentation](https://pm2.keymetrics.io/)

---

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review AWS CloudWatch logs
3. Check application logs on each server
4. Verify security group rules
5. Test connectivity between tiers

---

## 📝 Notes

- **Security**: This guide uses private subnets for application servers. Always use bastion hosts or Session Manager for SSH access.
- **Cost**: Remember to terminate resources when not needed to avoid charges.
- **Scalability**: This manual setup creates single instances. For production, consider Auto Scaling Groups.
- **Monitoring**: Set up CloudWatch alarms for CPU, memory, and disk usage.
- **Backups**: Implement automated database backups using AWS Backup or cron jobs.

---

**🎉 Congratulations!** You've successfully deployed the BMI Health Tracker manually!

For automated deployment using Terraform, see the `terraform/` directory.

---

## 🧑‍💻 Author

**Md. Sarowar Alam**  
Lead DevOps Engineer, Hogarth Worldwide  
📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: [linkedin.com/in/sarowar](https://www.linkedin.com/in/sarowar/)

---

---
