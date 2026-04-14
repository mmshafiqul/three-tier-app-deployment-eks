# Jenkins Pipeline for Terraform Deployment

This directory contains a Jenkins pipeline configuration for automating Terraform deployments of the BMI Health Tracker application.

## 📋 Overview

The `Jenkinsfile` provides a complete CI/CD pipeline that:
- ✅ Checks out code from Git
- ✅ Validates Terraform configuration
- ✅ Creates execution plans
- ✅ Applies infrastructure changes
- ✅ Displays deployment outputs
- ✅ Supports destroy operations

---

## 🚀 Quick Start

### 1. Prerequisites

**Jenkins Setup:**
- Jenkins 2.x or higher installed
- Required plugins:
  - Pipeline Plugin
  - Git Plugin
  - Credentials Plugin
  - AWS Credentials Plugin (optional)

**Jenkins Agent Requirements:**
- Terraform >= 1.0 installed
- AWS CLI configured
- Git installed
- `jq` installed (for JSON parsing)

### 2. Configure Jenkins Credentials

Go to **Jenkins → Manage Jenkins → Credentials** and add:

**AWS Credentials** (ID: `aws-credentials-id`):
- Kind: Secret file or AWS Credentials
- Scope: Global
- ID: `aws-credentials-id`
- Description: AWS credentials for Terraform

**Alternative**: Use AWS IAM role attached to Jenkins EC2 instance

### 3. Create Jenkins Pipeline Job

1. **New Item** → Enter name → **Pipeline**
2. **Pipeline section**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/sarowar-alam/3-tier-app-terraform-jenkins.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
3. **Save**

### 4. Configure Job Parameters

The pipeline accepts these parameters:

| Parameter | Type | Options | Description |
|-----------|------|---------|-------------|
| `ACTION` | Choice | plan, apply, destroy | Terraform action to perform |
| `AUTO_APPROVE` | Boolean | true/false | Skip manual approval (use carefully!) |

---

## 📊 Pipeline Stages

### Stage 1: Checkout
- Cleans workspace
- Checks out code from Git
- Displays commit information

### Stage 2: Verify Prerequisites
- Checks Terraform installation
- Checks AWS CLI installation
- Verifies required files exist

### Stage 3: Terraform Init
- Initializes Terraform
- Configures S3 backend
- Downloads provider plugins

### Stage 4: Terraform Validate
- Validates configuration syntax
- Checks for errors

### Stage 5: Terraform Format Check
- Checks code formatting
- Warns if files need formatting

### Stage 6: Terraform Plan
- Creates execution plan
- Archives plan file as artifact
- Only runs for `plan` or `apply` actions

### Stage 7: Approval for Apply
- Waits for manual approval
- Skipped if `AUTO_APPROVE=true`
- Only for `apply` action

### Stage 8: Terraform Apply
- Applies the infrastructure changes
- Uses previously created plan
- Only for `apply` action

### Stage 9: Approval for Destroy
- Requires typing "destroy" to confirm
- Extra safety for destructive action
- Only for `destroy` action

### Stage 10: Terraform Destroy
- Destroys all infrastructure
- Requires confirmation
- Only for `destroy` action

### Stage 11: Terraform Output
- Displays deployment outputs
- Shows application URL
- Only after successful apply

---

## 🎮 Usage Examples

### Plan Infrastructure Changes

1. Go to Jenkins job
2. Click **Build with Parameters**
3. Select:
   - `ACTION`: **plan**
   - `AUTO_APPROVE`: (doesn't matter for plan)
4. Click **Build**
5. Review plan in console output

### Apply Infrastructure

**Option A: With Manual Approval (Recommended)**
1. Click **Build with Parameters**
2. Select:
   - `ACTION`: **apply**
   - `AUTO_APPROVE`: **false**
3. Click **Build**
4. Review plan
5. Click **Proceed** when prompted
6. Wait for deployment to complete

**Option B: Auto-Approve (Use with Caution)**
1. Click **Build with Parameters**
2. Select:
   - `ACTION`: **apply**
   - `AUTO_APPROVE`: **true**
3. Click **Build**
4. Pipeline applies without waiting

### Destroy Infrastructure

1. Click **Build with Parameters**
2. Select:
   - `ACTION`: **destroy**
   - `AUTO_APPROVE`: **false**
3. Click **Build**
4. Type "destroy" when prompted
5. Confirm destruction

---

## 🔧 Configuration

### Customizing the Jenkinsfile

Edit these environment variables in the Jenkinsfile:

```groovy
environment {
    // Terraform version
    TF_VERSION = '1.6.0'
    
    // AWS credentials ID from Jenkins
    AWS_CREDENTIALS = credentials('aws-credentials-id')
    
    // Path to backend config
    TF_BACKEND_CONFIG = 'terraform/backend-config.tfbackend'
    
    // Path to variables file
    TF_VARS_FILE = 'terraform/terraform.tfvars'
    
    // Terraform working directory
    TF_WORKING_DIR = 'terraform'
}
```

### AWS Credentials Configuration

**Method 1: Jenkins Credentials**
```groovy
environment {
    AWS_CREDENTIALS = credentials('aws-credentials-id')
}
```

**Method 2: IAM Role (Recommended for EC2)**
Remove the `AWS_CREDENTIALS` line and attach an IAM role to the Jenkins EC2 instance.

**Method 3: Environment Variables**
```groovy
environment {
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    AWS_DEFAULT_REGION = 'ap-south-1'
}
```

---

## 📝 Jenkins Agent Setup

### Install Terraform on Jenkins Agent

```bash
# Download Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# Unzip
unzip terraform_1.6.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify
terraform version
```

### Install AWS CLI

```bash
# For Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

### Install jq (JSON Parser)

```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y jq

# Verify
jq --version
```

---

## 🔒 Security Best Practices

### 1. **Never Commit Sensitive Files**
Ensure `.gitignore` includes:
```
terraform.tfvars
backend-config.tfbackend
*.tfstate
*.tfstate.*
```

### 2. **Use Jenkins Credentials Store**
- Store AWS credentials securely in Jenkins
- Never hardcode credentials in Jenkinsfile

### 3. **Require Approval for Apply/Destroy**
- Keep `AUTO_APPROVE=false` for production
- Use auto-approve only for dev/test environments

### 4. **Use Separate AWS Accounts**
- Dev environment: Auto-approve allowed
- Staging: Manual approval required
- Production: Manual approval + additional reviews

### 5. **Enable State Locking**
Add to `backend-config.tfbackend`:
```hcl
dynamodb_table = "terraform-state-lock"
```

---

## 📊 Monitoring & Notifications

### Email Notifications

Uncomment and configure in the `post` section:

```groovy
post {
    success {
        emailext (
            subject: "✅ Terraform Deployment Success: ${env.JOB_NAME}",
            body: """
                Build: ${env.BUILD_NUMBER}
                Action: ${params.ACTION}
                Status: SUCCESS
                
                View: ${env.BUILD_URL}
            """,
            to: 'devops@example.com'
        )
    }
    
    failure {
        emailext (
            subject: "❌ Terraform Deployment Failed: ${env.JOB_NAME}",
            body: """
                Build: ${env.BUILD_NUMBER}
                Action: ${params.ACTION}
                Status: FAILED
                
                View: ${env.BUILD_URL}console
            """,
            to: 'devops@example.com'
        )
    }
}
```

### Slack Notifications

Install **Slack Notification Plugin** and add:

```groovy
post {
    success {
        slackSend (
            color: 'good',
            message: "✅ Terraform ${params.ACTION} succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
    
    failure {
        slackSend (
            color: 'danger',
            message: "❌ Terraform ${params.ACTION} failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

---

## 🐛 Troubleshooting

### Issue: "Terraform not found"

**Solution**: Install Terraform on Jenkins agent
```bash
sudo wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
sudo unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Issue: "AWS credentials not found"

**Solution**: 
1. Add AWS credentials to Jenkins credentials store
2. Or attach IAM role to Jenkins EC2 instance
3. Or configure AWS CLI: `aws configure`

### Issue: "Backend initialization failed"

**Solution**:
1. Verify S3 bucket exists
2. Check bucket name in `backend-config.tfbackend`
3. Ensure AWS credentials have S3 access

### Issue: "Permission denied on tfplan file"

**Solution**:
```groovy
// Add to post section
post {
    always {
        sh 'chmod 644 terraform/tfplan || true'
        sh 'rm -f terraform/tfplan'
    }
}
```

### Issue: Pipeline hangs at approval

**Solution**: Check Jenkins is accessible and not in safe mode
- Go to **Manage Jenkins** → **In-process Script Approval**
- Approve pending scripts if any

---

## 🔄 Advanced Features

### Multi-Environment Support

Create separate Jenkinsfiles or use parameters:

```groovy
parameters {
    choice(
        name: 'ENVIRONMENT',
        choices: ['dev', 'staging', 'production'],
        description: 'Target environment'
    )
    choice(
        name: 'ACTION',
        choices: ['plan', 'apply', 'destroy'],
        description: 'Terraform action'
    )
}

environment {
    TF_VARS_FILE = "terraform/terraform-${params.ENVIRONMENT}.tfvars"
}
```

### Parallel Execution

For multiple environments:

```groovy
stage('Deploy to Multiple Environments') {
    parallel {
        stage('Dev') {
            steps {
                sh 'terraform apply -var-file=terraform-dev.tfvars'
            }
        }
        stage('Staging') {
            steps {
                sh 'terraform apply -var-file=terraform-staging.tfvars'
            }
        }
    }
}
```

### Scheduled Deployments

In Jenkins job configuration:
- **Build Triggers** → **Build periodically**
- Schedule: `H 2 * * *` (Daily at 2 AM)

---

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Terraform in CI/CD](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform)
- [Jenkins Credentials Plugin](https://plugins.jenkins.io/credentials/)
- [AWS Credentials Plugin](https://plugins.jenkins.io/aws-credentials/)

---

## 🎓 For Students

This Jenkins pipeline demonstrates:
- ✅ **CI/CD Automation** - Automated infrastructure deployment
- ✅ **GitOps Principles** - Infrastructure as code in Git
- ✅ **Approval Gates** - Manual approval for critical changes
- ✅ **Error Handling** - Proper validation and rollback
- ✅ **Best Practices** - Security, monitoring, and documentation

---

**🎉 You now have a production-ready Jenkins pipeline for Terraform!**

For questions or issues, check the troubleshooting section or Jenkins console logs.

---

## 🧑‍💻 Author

**Md. Sarowar Alam**  
Lead DevOps Engineer, Hogarth Worldwide  
📧 Email: sarowar@hotmail.com  
🔗 LinkedIn: [linkedin.com/in/sarowar](https://www.linkedin.com/in/sarowar/)

---

---
