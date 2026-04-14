# AWS EKS Deployment Guide

This guide will walk you through deploying the BMI Health Tracker application to AWS EKS.

## Prerequisites

- AWS CLI installed and configured
- Docker installed
- Terraform >= 1.0 installed
- kubectl installed
- AWS account with appropriate permissions
- Docker Hub account (or ECR)

## Step 1: Build and Push Docker Images

### Option A: Docker Hub

```bash
# Build images
cd backend
docker build -t <your-dockerhub-username>/bmi-backend:v1 .
cd ../frontend
docker build -t <your-dockerhub-username>/bmi-frontend:v1 .
cd ../database
docker build -t <your-dockerhub-username>/bmi-database:v1 .

# Push images
docker push <your-dockerhub-username>/bmi-backend:v1
docker push <your-dockerhub-username>/bmi-frontend:v1
docker push <your-dockerhub-username>/bmi-database:v1
```

### Option B: Amazon ECR

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.us-east-1.amazonaws.com

# Create repositories
aws ecr create-repository --repository-name bmi-backend
aws ecr create-repository --repository-name bmi-frontend
aws ecr create-repository --repository-name bmi-database

# Build and tag images
cd backend
docker build -t <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/bmi-backend:v1 .
cd ../frontend
docker build -t <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/bmi-frontend:v1 .
cd ../database
docker build -t <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/bmi-database:v1 .

# Push images
docker push <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/bmi-backend:v1
docker push <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/bmi-frontend:v1
docker push <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/bmi-database:v1
```

## Step 2: Update Kubernetes Manifests

Update the image references in your Kubernetes manifests to use your Docker images:

```bash
# Update k8s/backend/deployment.yaml
# Change: image: mmshafiqul/bmi-backend:v1
# To: image: <your-image-registry>/bmi-backend:v1

# Update k8s/frontend/deployment.yaml
# Change: image: mmshafiqul/bmi-frontend:v1
# To: image: <your-image-registry>/bmi-frontend:v1

# Update k8s/database/deployment.yaml
# Change: image: mmshafiqul/bmi-database:v1
# To: image: <your-image-registry>/bmi-database:v1
```

## Step 3: Configure Terraform Backend

Create an S3 bucket for Terraform state:

```bash
aws s3 mb s3://your-terraform-state-bucket-name --region us-east-1

# Optional: Enable versioning
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket-name --versioning-configuration Status=Enabled

# Optional: Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Create the backend config file:

```bash
cd terraform
cp backend-config.tfbackend.example backend-config.tfbackend
nano backend-config.tfbackend
```

Update with your values:
```hcl
bucket = "your-terraform-state-bucket-name"
key    = "3-tier-app/terraform.tfstate"
region = "us-east-1"
dynamodb_table = "terraform-state-lock"
```

## Step 4: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Update with your values:
- region: Your AWS region
- profile: Your AWS profile
- ami_id: AMI ID for your region
- key_name: Your EC2 key pair name
- subnet CIDR blocks
- EKS configuration

## Step 5: Deploy Infrastructure with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init -backend-config=backend-config.tfbackend

# Plan deployment
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan
```

This will create:
- VPC with public and private subnets
- Internet Gateway
- Route tables
- Bastion host
- EKS cluster
- EKS node group

## Step 6: Configure kubectl for EKS

```bash
# Get cluster name from Terraform output
export CLUSTER_NAME=$(terraform output -raw cluster_name)
export REGION=us-east-1

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verify connection
kubectl get nodes
```

## Step 7: Deploy Application to EKS

```bash
# Create namespace
kubectl apply -f ../k8s/namespace.yaml

# Create secrets (update with strong passwords)
kubectl apply -f ../k8s/secret.yaml

# Create configmap
kubectl apply -f ../k8s/configmap.yaml

# Create PVC for database
kubectl apply -f ../k8s/database/pvc.yaml

# Deploy database
kubectl apply -f ../k8s/database/deployment.yaml
kubectl apply -f ../k8s/database/service.yaml

# Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=database -n three-tier-app --timeout=300s

# Deploy backend
kubectl apply -f ../k8s/backend/deployment.yaml
kubectl apply -f ../k8s/backend/service.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n three-tier-app --timeout=300s

# Deploy frontend
kubectl apply -f ../k8s/frontend/deployment.yaml
kubectl apply -f ../k8s/frontend/service.yaml

# Wait for frontend to be ready
kubectl wait --for=condition=ready pod -l app=frontend -n three-tier-app --timeout=300s
```

## Step 8: Verify Deployment

```bash
# Check all pods
kubectl get pods -n three-tier-app

# Check services
kubectl get svc -n three-tier-app

# Get frontend service URL
kubectl get svc frontend-service -n three-tier-app
```

## Step 9: Access the Application

### Option A: LoadBalancer Service

If using LoadBalancer type for frontend service:

```bash
kubectl get svc frontend-service -n three-tier-app
# Access via the EXTERNAL-IP
```

### Option B: Port Forwarding

```bash
kubectl port-forward svc/frontend-service 8080:80 -n three-tier-app
# Access at http://localhost:8080
```

### Option C: Ingress Controller

Install an ingress controller and create an Ingress resource for custom domain access.

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars

# Delete Kubernetes resources first
kubectl delete -f ../k8s/ -n three-tier-app
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n three-tier-app
kubectl logs <pod-name> -n three-tier-app
```

### Database connection issues
```bash
kubectl exec -it <database-pod> -n three-tier-app -- psql -U bmi_user -d bmi_db
```

### Terraform state issues
```bash
terraform state list
terraform refresh
```

## Security Notes

- Update the default passwords in k8s/secret.yaml before deployment
- Restrict bastion host SSH access to your IP in production
- Enable HTTPS/TLS with a certificate manager
- Use IAM roles for service accounts (IRSA)
- Enable pod security policies
