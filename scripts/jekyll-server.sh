#!/bin/bash
# Comprehensive Jekyll Server Script

# Set strict error handling
set -e

# Define paths
JEKYLL_DIR="/Users/cameron/Projects/blog/jekyll-site"
GEMFILE_PATH="$JEKYLL_DIR/Gemfile"

echo "🚀 Jekyll Blog Development Server"
echo "=================================="

# Change to Jekyll directory
echo "📂 Changing to Jekyll directory..."
cd "$JEKYLL_DIR"
echo "   Current directory: $(pwd)"

# Verify Gemfile exists
if [[ ! -f "$GEMFILE_PATH" ]]; then
    echo "❌ Gemfile not found at $GEMFILE_PATH"
    exit 1
fi
echo "✅ Gemfile found"

# Set environment variables
export BUNDLE_GEMFILE="$GEMFILE_PATH"
export JEKYLL_ENV="development"

# Ruby version check
echo "🔧 Ruby Environment:"
echo "   Ruby: $(ruby --version)"
echo "   Bundler: $(bundle --version)"

# Install/update dependencies
echo "📦 Installing dependencies..."
bundle check >/dev/null 2>&1 || bundle install

# Verify Jekyll installation
echo "🧪 Testing Jekyll..."
bundle exec jekyll --version

# Start the server
echo "🌐 Starting Jekyll server..."
echo "   URL: http://localhost:4000"
echo "   Press Ctrl+C to stop"
echo ""

# Use exec to replace the shell process
exec bundle exec jekyll serve \
    --drafts \
    --livereload \
    --host 0.0.0.0 \
    --port 4000 \
    --incremental \
    --open-url
