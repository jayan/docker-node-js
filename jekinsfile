pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/jayan/node-js-application.git'
        EC2_HOST = 'ubuntu@13.235.76.63'
        IMAGE_NAME = 'node-api'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_REPO = 'cjayanth'
        DOCKER_TAG = 'latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pull the latest code from the Git repository
                git branch: 'master', url: "${GIT_REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Ensure build.sh has execute permissions
                    sh "chmod +x build.sh"
                    // Run the build.sh script to build and push the Docker image
                    sh "./build.sh"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    // SSH into EC2 instance and run Docker commands
                    sshagent (credentials: ['ec2-ssh-key-id']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} '
                            sudo docker pull ${DOCKER_REGISTRY}/${DOCKER_REPO}/${IMAGE_NAME}:${DOCKER_TAG} &&
                            sudo docker run -d -p 80:80 ${DOCKER_REGISTRY}/${DOCKER_REPO}/${IMAGE_NAME}:${DOCKER_TAG}
                        '
                        """
                    }
                }
            }
        }
    }
}
