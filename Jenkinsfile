pipeline {
    agent any
    
    environment {
        // Terraform version
        TF_VERSION = '1.6.0'
        
        // AWS credentials from Jenkins credentials store
        AWS_CREDENTIALS = credentials('aws-credentials-id')
        
        // Terraform backend config file
        TF_BACKEND_CONFIG = 'terraform/backend-config.tfbackend'
        
        // Terraform variables file
        TF_VARS_FILE = 'terraform/terraform.tfvars'
        
        // Working directory
        TF_WORKING_DIR = 'terraform'
        
        // Disable Terraform color output for better Jenkins console
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action to perform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto-approve Terraform apply/destroy (use with caution!)'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Checkout Code from Git'
                    echo '======================================'
                }
                
                // Clean workspace
                cleanWs()
                
                // Checkout code from Git
                checkout scm
                
                // Display Git info
                sh '''
                    echo "Git Branch: $(git rev-parse --abbrev-ref HEAD)"
                    echo "Git Commit: $(git rev-parse --short HEAD)"
                    echo "Git Author: $(git log -1 --pretty=format:'%an')"
                '''
            }
        }
        
        stage('Verify Prerequisites') {
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Verify Prerequisites'
                    echo '======================================'
                }
                
                sh '''
                    # Check if Terraform is installed
                    if ! command -v terraform &> /dev/null; then
                        echo "ERROR: Terraform is not installed!"
                        exit 1
                    fi
                    
                    echo "Terraform version:"
                    terraform version
                    
                    # Check if AWS CLI is installed
                    if ! command -v aws &> /dev/null; then
                        echo "ERROR: AWS CLI is not installed!"
                        exit 1
                    fi
                    
                    echo "AWS CLI version:"
                    aws --version
                    
                    # Check if required files exist
                    if [ ! -f "${TF_BACKEND_CONFIG}" ]; then
                        echo "ERROR: Backend config file not found: ${TF_BACKEND_CONFIG}"
                        exit 1
                    fi
                    
                    if [ ! -f "${TF_VARS_FILE}" ]; then
                        echo "ERROR: Variables file not found: ${TF_VARS_FILE}"
                        exit 1
                    fi
                    
                    echo "✅ All prerequisites verified"
                '''
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Terraform Initialize'
                    echo '======================================'
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        # Initialize Terraform with backend config
                        terraform init \
                            -backend-config=${TF_BACKEND_CONFIG} \
                            -upgrade \
                            -reconfigure
                        
                        echo "✅ Terraform initialized successfully"
                    '''
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Terraform Validate'
                    echo '======================================'
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        # Validate Terraform configuration
                        terraform validate
                        
                        echo "✅ Terraform configuration is valid"
                    '''
                }
            }
        }
        
        stage('Terraform Format Check') {
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Terraform Format Check'
                    echo '======================================'
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        # Check if files are properly formatted
                        if ! terraform fmt -check -recursive; then
                            echo "⚠️  Warning: Some files are not properly formatted"
                            echo "Run 'terraform fmt -recursive' to fix"
                        else
                            echo "✅ All files are properly formatted"
                        fi
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'plan' || params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Terraform Plan'
                    echo '======================================'
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        # Create execution plan
                        terraform plan \
                            -var-file=${TF_VARS_FILE} \
                            -out=tfplan \
                            -input=false
                        
                        echo "✅ Terraform plan created successfully"
                        echo ""
                        echo "Review the plan above before proceeding to apply"
                    '''
                }
                
                // Archive the plan file
                archiveArtifacts artifacts: "${TF_WORKING_DIR}/tfplan", fingerprint: true
            }
        }
        
        stage('Approval for Apply') {
            when {
                allOf {
                    expression { params.ACTION == 'apply' }
                    expression { params.AUTO_APPROVE == false }
                }
            }
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Waiting for Approval'
                    echo '======================================'
                    
                    def userInput = input(
                        id: 'UserInput',
                        message: 'Do you want to apply this Terraform plan?',
                        parameters: [
                            booleanParam(
                                defaultValue: false,
                                description: 'Check to approve and apply the plan',
                                name: 'APPROVE'
                            )
                        ]
                    )
                    
                    if (!userInput) {
                        error('Terraform apply was not approved')
                    }
                    
                    echo "✅ Terraform apply approved by user"
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Terraform Apply'
                    echo '======================================'
                    echo "Auto-approve: ${params.AUTO_APPROVE}"
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        # Apply the plan
                        terraform apply \
                            -input=false \
                            -auto-approve \
                            tfplan
                        
                        echo "✅ Terraform apply completed successfully"
                    '''
                }
            }
        }
        
        stage('Approval for Destroy') {
            when {
                allOf {
                    expression { params.ACTION == 'destroy' }
                    expression { params.AUTO_APPROVE == false }
                }
            }
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Waiting for Destroy Approval'
                    echo '======================================'
                    
                    def userInput = input(
                        id: 'UserInput',
                        message: '⚠️  WARNING: This will DESTROY all infrastructure! Are you sure?',
                        parameters: [
                            string(
                                defaultValue: '',
                                description: 'Type "destroy" to confirm',
                                name: 'CONFIRMATION'
                            )
                        ]
                    )
                    
                    if (userInput != 'destroy') {
                        error('Destroy confirmation failed. You must type "destroy" to proceed.')
                    }
                    
                    echo "⚠️  Terraform destroy confirmed by user"
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Terraform Destroy'
                    echo '======================================'
                    echo "⚠️  WARNING: Destroying all infrastructure"
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        # Destroy infrastructure
                        terraform destroy \
                            -var-file=${TF_VARS_FILE} \
                            -auto-approve \
                            -input=false
                        
                        echo "✅ Terraform destroy completed"
                    '''
                }
            }
        }
        
        stage('Terraform Output') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo '======================================'
                    echo 'Stage: Display Terraform Outputs'
                    echo '======================================'
                }
                
                dir("${TF_WORKING_DIR}") {
                    sh '''
                        echo "Terraform Outputs:"
                        echo "=================="
                        terraform output -json | jq -r 'to_entries[] | "\\(.key) = \\(.value.value)"'
                        echo ""
                        echo "Application URL:"
                        terraform output -raw application_url || echo "Not available yet"
                        echo ""
                        echo "✅ Deployment completed successfully!"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo '======================================'
                echo 'Pipeline Finished'
                echo '======================================'
            }
            
            // Clean up plan file
            dir("${TF_WORKING_DIR}") {
                sh 'rm -f tfplan'
            }
        }
        
        success {
            script {
                echo '✅ Pipeline completed successfully!'
                
                // Send notification (optional - configure as needed)
                // emailext (
                //     subject: "Jenkins Pipeline Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                //     body: "Terraform ${params.ACTION} completed successfully.",
                //     to: 'team@example.com'
                // )
            }
        }
        
        failure {
            script {
                echo '❌ Pipeline failed!'
                
                // Send notification (optional - configure as needed)
                // emailext (
                //     subject: "Jenkins Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                //     body: "Terraform ${params.ACTION} failed. Check Jenkins console for details.",
                //     to: 'team@example.com'
                // )
            }
        }
        
        aborted {
            script {
                echo '⚠️  Pipeline was aborted by user'
            }
        }
    }
}
