#!/bin/bash
# Quick Ruby Environment Setup Script for Jekyll Blog

set -e  # Exit on any error

echo "🚀 Setting up Ruby environment for Jekyll blog..."

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

# Check if Homebrew Ruby is already installed
if command -v /opt/homebrew/bin/ruby >/dev/null 2>&1; then
    echo "✅ Homebrew Ruby already installed"
    ruby_version=$(/opt/homebrew/bin/ruby --version)
    echo "   Version: $ruby_version"
else
    execute_task "Installing Homebrew Ruby" "brew install ruby"
fi

# Update shell configuration
ZSHRC_PATH="$HOME/.zshrc"
RUBY_PATH_CONFIG='
# Ruby environment for Jekyll development
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"'

if ! grep -q "Ruby environment for Jekyll" "$ZSHRC_PATH" 2>/dev/null; then
    execute_task "Updating shell configuration" "echo '$RUBY_PATH_CONFIG' >> '$ZSHRC_PATH'"
else
    echo "✅ Shell configuration already updated"
fi

# Source the updated configuration
execute_task "Loading new Ruby environment" "source '$ZSHRC_PATH'"

# Verify Ruby installation
execute_task "Verifying Ruby installation" "/opt/homebrew/bin/ruby --version"

echo "🎉 Ruby environment setup complete!"
echo "📝 Next steps:"
echo "   1. Open a new terminal (or run: source ~/.zshrc)"
echo "   2. Navigate to jekyll-site directory"
echo "   3. Run: bundle install"
echo "   4. Run: bundle exec jekyll serve"

# Self-destruct
echo "🗑️ Removing setup script..."
rm "$0"
