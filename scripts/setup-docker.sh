#!/bin/bash
# Docker Development Environment Setup

set -e

echo "🐳 Setting up Docker-based blog development environment..."

function execute_task() {
    local task_name="$1"
    local command="$2"
    
    echo "📋 $task_name"
    if eval "$command"; then
        echo "✅ $task_name - Complete"
    else
        echo "❌ $task_name - Failed" >&2
        exit 1
    fi
    echo
}

# Check Docker installation
execute_task "Checking Docker installation" "docker --version && docker-compose --version"

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Use simplified Gemfile for Docker
if [[ -f jekyll-site/Gemfile.docker ]]; then
    execute_task "Using Docker-optimized Gemfile" "cp jekyll-site/Gemfile.docker jekyll-site/Gemfile"
fi

# Build and start containers
execute_task "Building Docker containers" "docker-compose build"
execute_task "Starting development servers" "docker-compose up -d"

# Wait for servers to start
echo "⏳ Waiting for servers to start..."
sleep 5

# Check container status
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🎉 Docker environment ready!"
echo "📝 Available services:"
echo "   Jekyll: http://localhost:4000"
echo "   Hugo:   http://localhost:1313"
echo ""
echo "🔧 Useful commands:"
echo "   View logs:     docker-compose logs -f"
echo "   Stop servers:  docker-compose down"
echo "   Restart:       docker-compose restart"
echo "   Shell access:  docker-compose exec jekyll sh"

# Self-destruct
echo "🗑️ Removing setup script..."
rm "$0"
