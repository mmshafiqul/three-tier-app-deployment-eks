# 3-Tier Application Deployment Guide - AWS EKS

This guide provides step-by-step instructions to deploy a 3-tier application (database, backend, frontend) on AWS EKS using Terraform and Kubernetes.

## Prerequisites

- AWS CLI installed and configured with credentials
- Terraform installed
- kubectl installed
- Docker installed
- Docker Hub account
- GitHub account

## Architecture

- **Database**: PostgreSQL 14 with emptyDir volume (for testing)
- **Backend**: Node.js API server
- **Frontend**: React/Vue application with Nginx
- **Infrastructure**: AWS EKS cluster with public subnets
- **Load Balancer**: AWS Classic Load Balancer for frontend access

---

## Part 1: Infrastructure Deployment with Terraform

### 1. Clone the Repository

```bash
git clone https://github.com/mmshafiqul/three-tier-app-deployment-eks.git
cd three-tier-app-deployment-eks
```

### 2. Configure Terraform Variables

Create `terraform/terraform.tfvars`:

```hcl
region = "ap-south-1"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
bastion_instance_type = "t2.micro"
bastion_ami_id = "ami-0c02fb55956c1d4ba"  # Ubuntu AMI for ap-south-1
kubernetes_version = "1.29"
node_instance_type = "t2.medium"
desired_size = 3
max_size = 3
min_size = 3
tags = {
  Name = "three-tier-app"
  Environment = "production"
}
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Deploy Infrastructure

```bash
terraform apply -auto-approve
```

This will create:
- VPC with 3 public and 3 private subnets
- Internet Gateway
- Route tables
- Bastion EC2 instance
- EKS cluster (Kubernetes 1.29)
- EKS node group (3 nodes in public subnets)

### 5. Get Bastion IP

```bash
terraform output bastion_public_ip
```

### 6. Connect to Bastion Host

```bash
ssh -i /path/to/your/key.pem ubuntu@<bastion-public-ip>
```

---

## Part 2: Configure Bastion Host

### 1. Configure AWS Credentials

```bash
aws configure
```

Enter your AWS Access Key ID and Secret Access Key.

### 2. Verify kubectl Connection to EKS

```bash
aws eks update-kubeconfig --name three-tier-app-eks-cluster --region ap-south-1
kubectl get nodes
```

You should see 3 nodes in Ready state.

---

## Part 3: Build and Push Docker Images

### 1. Build Database Image

```bash
cd database
docker build -t mmshafiqul/bmi-database:v1 .
docker push mmshafiqul/bmi-database:v1
```

### 2. Build Backend Image

```bash
cd backend
docker build -t mmshafiqul/bmi-backend:v1 .
docker push mmshafiqul/bmi-backend:v1
```

### 3. Build Frontend Image

```bash
cd frontend
docker build -t mmshafiqul/bmi-frontend:v2 .
docker push mmshafiqul/bmi-frontend:v2
```

---

## Part 4: Deploy Kubernetes Manifests

### 1. Clone Repository on Bastion

```bash
cd ~
git clone https://github.com/mmshafiqul/three-tier-app-deployment-eks.git
cd three-tier-app-deployment-eks/k8s
```

### 2. Create Namespace

```bash
kubectl apply -f namespace.yaml
```

### 3. Create ConfigMap

```bash
kubectl apply -f configmap.yaml
```

### 4. Create Secret

```bash
kubectl apply -f secret.yaml
```

### 5. Create StorageClass (for testing with emptyDir, not required but available)

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-immediate
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOF
```

### 6. Deploy Database

```bash
kubectl apply -f database/deployment.yaml
kubectl apply -f database/service.yaml
kubectl apply -f database/pvc.yaml
```

### 7. Deploy Backend

```bash
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
```

### 8. Deploy Frontend

```bash
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
```

### 9. Apply Resource Quota

```bash
kubectl apply -f quota.yaml
```

---

## Part 5: Verify Deployment

### 1. Check Pod Status

```bash
kubectl get pods -n three-tier-app
```

Expected output:
```
NAME                                   READY   STATUS    RESTARTS   AGE
backend-deployment-xxxxx               1/1     Running   0          Xs
database-xxxxx                         1/1     Running   0          Xs
frontend-deployment-xxxxx              1/1     Running   0          Xs
```

### 2. Check Services

```bash
kubectl get svc -n three-tier-app
```

Expected output:
```
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
backend-service    ClusterIP      172.20.XX.XX     <none>                                                                    3000/TCP       XXm
database-service   ClusterIP      172.20.XX.XX     <none>                                                                    5432/TCP       XXm
frontend-service   LoadBalancer   172.20.XX.XX     <aws-load-balancer-url>                                                 80:XXXXX/TCP   XXm
```

### 3. Access Application

Get the LoadBalancer URL:
```bash
kubectl get svc frontend-service -n three-tier-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Open the LoadBalancer URL in your browser or test with curl:
```bash
curl http://<load-balancer-url>
```

---

## Part 6: Clean Up (Optional)

### 1. Delete Kubernetes Resources

```bash
kubectl delete namespace three-tier-app
```

### 2. Destroy Terraform Infrastructure

```bash
cd terraform
terraform destroy -auto-approve
```

---

## Important Configuration Notes

### Database Configuration
- Uses emptyDir for testing (data is lost when pod restarts)
- Credentials: User `bmi_user`, Password `admin123`, Database `bmi_db`
- Connection string: `postgresql://bmi_user:admin123@database-service:5432/bmi_db`

### Backend Configuration
- Environment variables from ConfigMap and Secret
- DATABASE_URL is set in ConfigMap for database connection
- API runs on port 3000

### Frontend Configuration
- Nginx proxies API requests to backend-service:3000
- Uses LoadBalancer type for external access
- Updated nginx.conf uses `backend-service` as upstream

### Kubernetes Namespace
- All resources deployed in `three-tier-app` namespace

---

## Troubleshooting

### Check Pod Logs
```bash
kubectl logs <pod-name> -n three-tier-app
```

### Describe Pod
```bash
kubectl describe pod <pod-name> -n three-tier-app
```

### Check Events
```bash
kubectl get events -n three-tier-app --sort-by='.lastTimestamp'
```

### Restart Deployment
```bash
kubectl rollout restart deployment <deployment-name> -n three-tier-app
```

---

## Summary

This deployment successfully creates:
- AWS EKS cluster with 3 worker nodes
- PostgreSQL database with emptyDir volume
- Node.js backend API server
- React/Vue frontend with Nginx
- LoadBalancer for external access

All components are running in the `three-tier-app` namespace on AWS EKS.
