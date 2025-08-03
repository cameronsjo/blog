#!/bin/bash
# GitHub CLI Repository Creation and Setup Script

set -e

echo "🚀 Creating GitHub repository using GitHub CLI..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "📦 GitHub CLI not found. Installing via Homebrew..."
    brew install gh
    echo "✅ GitHub CLI installed successfully!"
fi

# Check if user is authenticated
echo "🔐 Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    echo "🔑 Please authenticate with GitHub..."
    gh auth login
fi

echo "✅ GitHub authentication confirmed!"

# Get repository details
repo_name="blog"
repo_description="Dual static site generator blog with Jekyll and Hugo - featuring Docker development environment and comprehensive documentation"

echo ""
echo "📋 Repository Details:"
echo "   Name: $repo_name"
echo "   Description: $repo_description"
echo "   Visibility: Public (required for GitHub Pages)"
echo ""

# Create repository on GitHub
echo "🏗️ Creating repository on GitHub..."
gh repo create "$repo_name" \
    --description "$repo_description" \
    --public \
    --clone=false \
    --add-readme=false

echo "✅ Repository created successfully!"

# Add remote origin
echo "🔗 Adding remote origin..."
git remote add origin "https://github.com/$(gh api user --jq .login)/$repo_name.git"

# Push to GitHub
echo "📤 Pushing code to GitHub..."
git push -u origin main

# Get the username for URLs
username=$(gh api user --jq .login)

echo ""
echo "🎉 Blog successfully deployed to GitHub!"
echo ""
echo "🌐 Your repositories:"
echo "   GitHub: https://github.com/$username/$repo_name"
echo "   Clone: git clone https://github.com/$username/$repo_name.git"
echo ""
echo "📄 GitHub Pages setup:"
echo "   1. Automatic setup starting..."

# Enable GitHub Pages programmatically
echo "⚙️ Enabling GitHub Pages..."
gh api repos/$username/$repo_name/pages \
    --method POST \
    --field source='{"branch":"main","path":"/"}' \
    --field build_type="legacy" 2>/dev/null || echo "   (GitHub Pages may already be configured or will be available shortly)"

echo ""
echo "🌍 Your blog will be available at:"
echo "   📝 GitHub Pages: https://$username.github.io/$repo_name"
echo "   ⏰ Note: GitHub Pages deployment may take 5-10 minutes"
echo ""
echo "🔧 Local development (still running):"
echo "   Jekyll: http://localhost:4000"
echo "   Hugo: http://localhost:1313"
echo ""
echo "📚 Documentation:"
echo "   Setup Guide: https://github.com/$username/$repo_name/blob/main/GETTING_STARTED.md"
echo "   Docker Guide: https://github.com/$username/$repo_name/blob/main/DOCKER.md"
echo "   Deployment: https://github.com/$username/$repo_name/blob/main/DEPLOYMENT.md"
echo ""
echo "🎊 Next steps:"
echo "   1. Wait for GitHub Pages deployment"
echo "   2. Create your first blog post"
echo "   3. Customize your Jekyll/Hugo themes"
echo "   4. Set up custom domain (optional)"

# Self-destruct
echo ""
echo "🗑️ Removing setup script..."
rm "$0"
