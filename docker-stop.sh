#!/bin/bash

# Docker Stop Script for BMI Health Tracker Three-Tier App
# This script stops and removes all containers

set -e

echo "=========================================="
echo "Stopping BMI Health Tracker Containers"
echo "=========================================="

# Stop and remove containers
echo "Stopping containers..."
docker stop bmi-frontend bmi-backend bmi-database 2>/dev/null || echo "Some containers already stopped"

echo "Removing containers..."
docker rm bmi-frontend bmi-backend bmi-database 2>/dev/null || echo "Some containers already removed"

echo "=========================================="
echo "All containers stopped and removed!"
echo "=========================================="
echo ""
echo "To remove the network:"
echo "  docker network rm bmi-network"
echo ""
echo "To remove the volume (WARNING: This will delete all data):"
echo "  docker volume rm postgres_data"
