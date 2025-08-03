#!/bin/bash

# GitHub Pages Deployment Setup Script
# This script commits the workflow changes and configures GitHub Pages

set -e

function log_success() {
    echo "✅ $1"
}

function log_info() {
    echo "ℹ️  $1"
}

function log_error() {
    echo "❌ $1" >&2
}

# Change to blog directory
cd "/Users/cameron/Projects/blog"

log_info "Committing GitHub Actions workflow updates..."

# Add and commit the workflow changes
git add .github/workflows/
git commit -m "fix: update GitHub Actions workflows with proper permissions

- Add explicit permissions for GitHub Pages deployment
- Update to actions/upload-pages-artifact@v3 and actions/deploy-pages@v4
- Create alternative pages.yml workflow using official GitHub Pages actions
- Resolve github-actions[bot] permission denied errors
- Enable automated deployment from main branch"

log_success "Committed workflow updates"

# Push changes to trigger GitHub Actions
log_info "Pushing changes to GitHub..."
git push origin main

log_success "Changes pushed to GitHub"

log_info "Next steps:"
echo "1. Go to GitHub repository settings"
echo "2. Navigate to Pages section"
echo "3. Set Source to 'GitHub Actions'"
echo "4. The workflows will now deploy automatically on push"

echo ""
log_info "Alternative CLI setup (if you have gh CLI):"
echo "gh api repos/cameronsjo/blog/pages --method POST --field source.branch=main --field source.path=/"

log_success "GitHub Pages deployment setup complete!"

# Self-destruct
rm "$0"
