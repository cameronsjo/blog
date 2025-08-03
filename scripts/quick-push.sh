#!/bin/bash
# Quick GitHub Push Script

set -e

echo "🔗 Adding GitHub remote..."
git remote add origin https://github.com/cameronsjo/blog.git

echo "📤 Pushing to GitHub..."
git push -u origin main

echo ""
echo "🎉 Blog successfully pushed to GitHub!"
echo ""
echo "🌐 Your repositories:"
echo "   GitHub: https://github.com/cameronsjo/blog"
echo "   Pages: https://cameronsjo.github.io/blog (after enabling)"
echo ""
echo "⚙️ Enable GitHub Pages:"
echo "1. Go to: https://github.com/cameronsjo/blog/settings/pages"
echo "2. Source: Deploy from a branch"
echo "3. Branch: main / folder: / (root)"
echo "4. Click Save"
echo ""
echo "✨ Both Jekyll and Hugo sites are ready!"

# Self-destruct
rm "$0"
