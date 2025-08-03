#!/bin/bash
# Script to update all commit authors

set -e

echo "🔧 Updating commit authors for all commits..."

# Set the correct author information
export GIT_AUTHOR_NAME="Cameron Sjo"
export GIT_AUTHOR_EMAIL="cameron.sjo@me.com"
export GIT_COMMITTER_NAME="Cameron Sjo"
export GIT_COMMITTER_EMAIL="cameron.sjo@me.com"

# Use filter-branch to update all commits
echo "📝 Rewriting commit history with correct author..."
git filter-branch --env-filter '
    export GIT_AUTHOR_NAME="Cameron Sjo"
    export GIT_AUTHOR_EMAIL="cameron.sjo@me.com"
    export GIT_COMMITTER_NAME="Cameron Sjo"
    export GIT_COMMITTER_EMAIL="cameron.sjo@me.com"
' --tag-name-filter cat -- --branches --tags

echo "✅ All commits updated with correct author information!"

echo "📊 Updated commit log:"
git log --oneline --format="%h %s (Author: %an <%ae>)"

echo ""
echo "🚀 To push the updated history to GitHub:"
echo "   git push --force-with-lease origin main"
echo ""
echo "⚠️  Warning: This rewrites history. Only do this if you're the only contributor."

# Self-destruct
rm "$0"
