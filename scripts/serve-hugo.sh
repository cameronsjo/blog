#!/bin/bash
# Serve Hugo site locally

echo "🚀 Starting Hugo development server..."

cd "$(dirname "$0")/../hugo-site"
echo "Working directory: $(pwd)"

# Start Hugo with drafts enabled
hugo server -D --bind 0.0.0.0 --port 1313

echo "Hugo server stopped."
