// Jenkinsfile
pipeline {
    agent any // Or specify a Docker agent with necessary tools (node, docker, aws, terraform)

    environment {
        AWS_REGION               = 'us-east-1' // Change to your desired AWS region
        AWS_ACCOUNT_ID           = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
        ECR_REGISTRY             = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        FRONTEND_ECR_REPO_NAME   = 'portfolio-builder-frontend'
        BACKEND_ECR_REPO_NAME    = 'portfolio-builder-backend'
        IMAGE_TAG                = "build-${BUILD_NUMBER}"

        // ECS Variables (Ensure these match your Terraform outputs/names)
        ECS_CLUSTER_NAME         = 'portfolio-builder-cluster'
        FRONTEND_ECS_SERVICE_NAME = 'portfolio-frontend-service'
        BACKEND_ECS_SERVICE_NAME  = 'portfolio-backend-service'

        // Terraform directory
        TERRAFORM_DIR            = 'terraform'

        // Database credentials should be injected securely, e.g., from Jenkins credentials
        // For example, if you have Jenkins credentials with ID 'db-prod-creds'
        // with username and password:
        // DB_USERNAME = credentials('db-prod-creds_USR')
        // DB_PASSWORD = credentials('db-prod-creds_PSW')
        // These would then be passed to your backend container as environment variables
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'YOUR_GIT_REPOSITORY_URL' // <<< REPLACE THIS
                stash includes: '**/*', name: 'source'
            }
        }

        stage('Setup Tools & Login') {
            steps {
                script {
                    // Ensure AWS CLI can communicate with ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                }
            }
        }

        stage('Build & Push Frontend Image') {
            steps {
                unstash 'source'
                dir('frontend') {
                    script {
                        def imageName = "${ECR_REGISTRY}/${FRONTEND_ECR_REPO_NAME}"
                        def dockerImage = docker.build(imageName, "-f Dockerfile .")
                        dockerImage.push(IMAGE_TAG)
                        dockerImage.push('latest') // Also push 'latest' tag
                        echo "Pushed Frontend Image: ${imageName}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Build & Push Backend Image') {
            steps {
                unstash 'source'
                dir('backend') {
                    script {
                        def imageName = "${ECR_REGISTRY}/${BACKEND_ECR_REPO_NAME}"
                        // Example: If your backend Docker build needs DB credentials as build args (not recommended for secrets)
                        // or for non-sensitive build-time configurations.
                        // Secrets should be passed at runtime as environment variables.
                        def dockerImage = docker.build(imageName, "-f Dockerfile .")
                        dockerImage.push(IMAGE_TAG)
                        dockerImage.push('latest')
                        echo "Pushed Backend Image: ${imageName}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Terraform Apply (Infrastructure)') {
            // This stage is responsible for ensuring the infrastructure is up-to-date.
            // It's often run conditionally or as a separate pipeline.
            // For simplicity, it's included here.
            // Ensure Jenkins (or its agent) has Terraform installed and appropriate AWS permissions.
            when {
                // Example: Only run on main branch pushes, or trigger manually with parameters
                branch 'main'
                // Or use input step for manual approval:
                // input message: 'Proceed with Terraform Apply?'
            }
            steps {
                unstash 'source'
                dir(TERRAFORM_DIR) {
                    sh "terraform init -input=false"
                    // terraform plan -out=tfplan -input=false -var="db_password=${DB_PASSWORD}" // If passing variables
                    sh "terraform plan -out=tfplan -input=false" // Variables should be from tfvars or env for infra
                    // Add a manual approval step here in a real pipeline before apply
                    // input message: 'Approve Terraform Plan to Apply?'
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }

        stage('Deploy to ECS (Update Services)') {
            // This stage updates the ECS services to use the new Docker images.
            // A more robust deployment involves creating a new task definition revision
            // with the specific IMAGE_TAG, then updating the service to use that new revision.
            steps {
                script {
                    // Update Backend Service
                    // This simple approach relies on the task definition using the 'latest' tag
                    // or being updated separately to use the new IMAGE_TAG.
                    echo "Updating ECS Service: ${BACKEND_ECS_SERVICE_NAME} in cluster ${ECS_CLUSTER_NAME}"
                    sh """
                       aws ecs update-service \\
                         --cluster ${ECS_CLUSTER_NAME} \\
                         --service ${BACKEND_ECS_SERVICE_NAME} \\
                         --force-new-deployment \\
                         --region ${AWS_REGION}
                    """

                    // Update Frontend Service
                    echo "Updating ECS Service: ${FRONTEND_ECS_SERVICE_NAME} in cluster ${ECS_CLUSTER_NAME}"
                    sh """
                       aws ecs update-service \\
                         --cluster ${ECS_CLUSTER_NAME} \\
                         --service ${FRONTEND_ECS_SERVICE_NAME} \\
                         --force-new-deployment \\
                         --region ${AWS_REGION}
                    """
                    echo "Deployment to ECS initiated."
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            cleanWs() // Cleans up the workspace
        }
        success {
            echo 'Deployment successful!'
            // Add notification steps (e.g., Slack, Email)
        }
        failure {
            echo 'Deployment failed.'
            // Add notification steps
        }
    }
}
