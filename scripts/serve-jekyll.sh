#!/bin/bash
# Serve Jekyll site locally

echo "🚀 Starting Jekyll development server..."

cd "$(dirname "$0")/../jekyll-site"
echo "Working directory: $(pwd)"

# Ensure we have the Gemfile
if [ ! -f "Gemfile" ]; then
    echo "❌ Gemfile not found in $(pwd)"
    exit 1
fi

# Set explicit bundle path
export BUNDLE_GEMFILE="$(pwd)/Gemfile"
echo "Using Gemfile: $BUNDLE_GEMFILE"

# Start Jekyll with live reload
bundle exec jekyll serve --livereload --drafts --port 4000 --host 0.0.0.0

echo "Jekyll server stopped."
