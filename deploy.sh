#!/bin/bash

# Login to Docker Hub


# Variables
IMAGE_NAME="node-api"
DOCKER_USERNAME="cjayanth"
TAG="latest"

# Build the Docker image
echo "Building Docker image..."
docker build -t ${IMAGE_NAME} .

# Run the Docker container
echo "Running Docker container..."
docker run -d -p 80:80 --name ${IMAGE_NAME} ${IMAGE_NAME}

# Tag the Docker image
echo "Tagging Docker image..."
docker tag ${IMAGE_NAME} ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

# Push the Docker image to Docker Hub
echo "Pushing Docker image to Docker Hub..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}

echo "Deployment complete!"
