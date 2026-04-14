#!/bin/bash

# Docker Run Script for BMI Health Tracker Three-Tier App
# This script builds and runs all containers using docker build and docker run commands

set -e

echo "=========================================="
echo "BMI Health Tracker - Docker Setup"
echo "=========================================="

# Create Docker network
echo "Creating Docker network..."
docker network create bmi-network 2>/dev/null || echo "Network already exists"

# Build database image
echo "Building database image..."
docker build -t bmi-database ./database

# Build backend image
echo "Building backend image..."
docker build -t bmi-backend ./backend

# Build frontend image
echo "Building frontend image..."
docker build -t bmi-frontend ./frontend

# Run database container
echo "Starting database container..."
docker run -d \
  --name bmi-database \
  --network bmi-network \
  -e POSTGRES_USER=bmi_user \
  -e POSTGRES_PASSWORD=admin1234 \
  -e POSTGRES_DB=bmi_db \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  bmi-database

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 10

# Run backend container
echo "Starting backend container..."
docker run -d \
  --name bmi-backend \
  --network bmi-network \
  -e DB_HOST=database \
  -e DB_PORT=5432 \
  -e DB_NAME=bmi_db \
  -e DB_USER=bmi_user \
  -e DB_PASSWORD=admin1234 \
  -e DATABASE_URL=postgresql://bmi_user:admin1234@database:5432/bmi_db \
  -e PORT=3000 \
  -e NODE_ENV=production \
  -e CORS_ORIGIN=http://localhost:80 \
  -p 3000:3000 \
  bmi-backend

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
sleep 5

# Run frontend container
echo "Starting frontend container..."
docker run -d \
  --name bmi-frontend \
  --network bmi-network \
  -p 80:80 \
  bmi-frontend

echo "=========================================="
echo "All containers started successfully!"
echo "=========================================="
echo ""
echo "Access the application at: http://localhost"
echo "Backend API at: http://localhost:3000"
echo "Database at: localhost:5432"
echo ""
echo "Check container status:"
echo "  docker ps"
echo ""
echo "View logs:"
echo "  docker logs bmi-database"
echo "  docker logs bmi-backend"
echo "  docker logs bmi-frontend"
echo ""
echo "Stop all containers:"
echo "  ./docker-stop.sh"
