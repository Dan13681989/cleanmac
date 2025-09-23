#!/bin/bash

# reset-docker-network.sh
# Reset Docker network settings and IP ranges on macOS

set -e

echo "🐳 Resetting Docker network configuration on macOS..."

# Stop all running containers
echo "Stopping all Docker containers..."
docker stop $(docker ps -q) 2>/dev/null || true

# Remove all containers
echo "Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null || true

# Remove all networks
echo "Cleaning up networks..."
docker network prune -f

# Restart Docker Desktop
echo "Restarting Docker Desktop..."
osascript -e 'quit app "Docker"' 2>/dev/null || true
sleep 5
open -a Docker
sleep 10

echo "✅ Docker network reset completed!"
echo "Default bridge network should now use: 192.168.100.0/24"
