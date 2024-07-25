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
