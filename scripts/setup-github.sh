#!/bin/bash
# GitHub Repository Setup Script

set -e

echo "🚀 Setting up GitHub repository for your blog..."

# Get user input
read -p "Enter your GitHub username: " github_username
read -p "Enter repository name (press Enter for 'blog'): " repo_name
repo_name=${repo_name:-blog}

# Construct repository URL
repo_url="https://github.com/${github_username}/${repo_name}.git"

echo ""
echo "📋 Repository Setup Summary:"
echo "   Username: $github_username"
echo "   Repository: $repo_name"
echo "   URL: $repo_url"
echo ""

# Check if user wants to proceed
read -p "Does this look correct? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Setup cancelled."
    exit 1
fi

echo ""
echo "📝 Next steps:"
echo "1. Create repository on GitHub.com:"
echo "   - Go to https://github.com/new"
echo "   - Repository name: $repo_name"
echo "   - Description: 'Dual static site generator blog with Jekyll and Hugo'"
echo "   - Set to Public (for GitHub Pages)"
echo "   - Do NOT initialize with README, .gitignore, or license"
echo ""
echo "2. After creating the repository, press Enter to continue..."
read -p "Press Enter when repository is created on GitHub..."

echo ""
echo "🔗 Configuring remote repository..."

# Add remote origin
git remote add origin "$repo_url"

# Push to GitHub
echo "📤 Pushing to GitHub..."
git push -u origin main

echo ""
echo "🎉 Repository setup complete!"
echo ""
echo "🌐 Your blog is now available at:"
echo "   Repository: https://github.com/${github_username}/${repo_name}"
if [[ $repo_name == "blog" ]]; then
    echo "   GitHub Pages: https://${github_username}.github.io/blog"
else
    echo "   GitHub Pages: https://${github_username}.github.io/${repo_name}"
fi
echo ""
echo "⚙️ To enable GitHub Pages:"
echo "1. Go to repository Settings → Pages"
echo "2. Source: 'Deploy from a branch'"
echo "3. Branch: 'main' / folder: '/ (root)'"
echo "4. Wait a few minutes for deployment"
echo ""
echo "🔧 Local development URLs:"
echo "   Jekyll: http://localhost:4000"
echo "   Hugo: http://localhost:1313"

# Self-destruct
echo ""
echo "🗑️ Removing setup script..."
rm "$0"
