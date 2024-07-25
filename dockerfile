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

