# node-js-application


Project Title: Continuous Integration and Deployment of Node.js Application with Jenkins, AWS EC2 and Docker.
 
Application:-
clone the below repositry 

Repo URL:- https://github.com/jayan/node-js-application.git

# Build the Node.js application:

# Build the Docker image:
create a dockerfile 

```bash
  nano dockerfile 
```
```bash
  # Stage 1: Install dependencies and run tests
FROM node:14-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json ./

# Install all dependencies including devDependencies for testing
RUN npm install

# Copy the entire application code to the working directory
COPY . .

# Run tests
RUN npm test

# Stage 2: Build the production image
FROM node:14-alpine AS production

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package.json ./

# Set the environment to production
ENV NODE_ENV=production

# Install only production dependencies
RUN npm install --only=production

# Copy the application code from the builder stage, excluding dev dependencies and test code
COPY --from=builder /app .

# Expose the port your app runs on
EXPOSE 80

# Define the command to run your app
CMD ["npm", "start"]
```

create build,sh file to build and push the image to dockerhub

```bash
  nano build.sh
```
```bash
  #!/bin/bash

# Login to Docker Hub
docker login -u cjayanth -p dckr_pat_b7SY8aUaMHV1wGURqY4jQoukKNI

# Variables
IMAGE_NAME="node-api"
DOCKER_USERNAME="cjayanth"
TAG="latest"

# Build the Docker image
echo "Building Docker image..."
docker build -t ${IMAGE_NAME} .

# Tag the Docker image
echo "Tagging Docker image..."
docker tag ${IMAGE_NAME} ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

# Push the Docker image to Docker Hub
echo "Pushing Docker image to Docker Hub..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

echo "Deployment complete!"
```

create a jenkins file 
```bash
  nano jenkinsfile
```
```bash
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
```
AWS:
Launch t2.micro instance and deploy the create application.
Configure SG as below:
Create a new security group and configure it to allow incoming traffic on port 22 (SSH) and 80 (HTTP).


#write a terraform script to Launch t2.micro instance and deploy the create application. Configure SG as below: 
create in terraform file 
```bash
provider "aws" {
  region = "us-east-1"  
}

# Define a security group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow inbound traffic on port 22 (SSH) and 80 (HTTP)"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

# Launch an EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0ad21ae1d0696ad58"  
  instance_type = "t2.micro"
  key_name      = "webserver"

  security_groups = [aws_security_group.allow_ssh_http.name]

  tags = {
    Name = "ec2"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update package list and install necessary packages
              sudo apt-get update -y
              sudo apt-get install ca-certificates curl gnupg lsb-release -y

              # Add Docker's official GPG key
              sudo mkdir -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc

              # Set up the Docker repository
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee 
              /etc/apt/sources.list.d/docker.list > /dev/null

              # Update package list again and install Docker
              sudo apt-get update -y
              sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

              # Start Docker service
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF
}

```

Upload everthing into a github using git commands 

# install jenkins using jenkins.sh file

install required plugins along with ssh agent plugin 
configure SSH credentials in Jenkins, go to "Manage Jenkins" > "Manage Credentials" > (Select Domain) > "Add Credentials" and choose "SSH Username with private key"


![6129782900174994849](https://github.com/user-attachments/assets/ce36fbb9-92e1-4e5c-a9e1-d6f1f1fad578)


![6129782900174994848](https://github.com/user-attachments/assets/d195d67a-bb9d-488a-aa65-e9e6fc6f5bff)

![6129782900174994850](https://github.com/user-attachments/assets/c86aed95-fa03-4801-8846-f6b210bcb5ab)

In Jenkins, create a pipeline by selecting "New Item", choosing "Pipeline", and in the "Pipeline" section, set "Definition" to "Pipeline script from SCM", then select "Git" and enter your GitHub repository URL, specifying the path to the Jenkinsfile.


![6129782900174994865 (1)](https://github.com/user-attachments/assets/5eb60cca-9235-4a3d-82c9-6b09cce80d43)

![6129782900174994854](https://github.com/user-attachments/assets/0a14fc52-f0d5-42bd-8cc9-45016a10663c)

![6129782900174994857](https://github.com/user-attachments/assets/cb031718-9882-47a5-92d8-bc5fc7bb7510)


![6129782900174994862](https://github.com/user-attachments/assets/963041e4-984c-4c37-8676-0df1434406a0)

![6129782900174994855](https://github.com/user-attachments/assets/611d6edc-8409-4dd7-aa38-c0e4a25ab72b)

save and apply and click on build 

![6129782900174994859](https://github.com/user-attachments/assets/5591de4f-9185-4578-9acc-8bb57184763c)

![6129782900174994858](https://github.com/user-attachments/assets/a82b2c3d-5b1e-4c8e-85c4-c92396bfed0d)

![6129782900174994856](https://github.com/user-attachments/assets/2b95bc96-67dd-4a36-9f25-7b66a8a1af45)


Now check the image is uploaded into dockerhub 

![6129782900174994879](https://github.com/user-attachments/assets/635f7775-99be-4508-99ca-e803b55bb830)

and chek the container status in ec2 and access it 

![6129782900174994878](https://github.com/user-attachments/assets/c9031f74-426e-4ad5-98bd-baacff69d5ca)

![6129782900174994871](https://github.com/user-attachments/assets/29009a1f-9930-4c23-bdb6-04c118723663)

