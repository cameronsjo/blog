#!/bin/bash
# Jekyll Development Server Script

echo "🚀 Starting Jekyll development server..."
cd "/Users/cameron/Projects/blog/jekyll-site"
echo "Working directory: $(pwd)"
echo "Gemfile exists: $(test -f Gemfile && echo 'YES' || echo 'NO')"

export BUNDLE_GEMFILE="/Users/cameron/Projects/blog/jekyll-site/Gemfile"
echo "🔧 Using Gemfile: $BUNDLE_GEMFILE"

echo "📦 Bundle status:"
bundle check || bundle install

echo "🌐 Starting Jekyll server..."
bundle exec jekyll serve --drafts --livereload --host 0.0.0.0 --port 4000

echo "🛑 Jekyll server stopped."
