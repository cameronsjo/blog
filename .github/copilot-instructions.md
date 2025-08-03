# GitHub Copilot Instructions for Blog Project

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Environment Context

- **Operating System**: macOS
- **Default Shell**: zsh
- **Project Type**: GitHub Pages Blog with Jekyll + Hugo
- **Build System**: Jekyll (Ruby) and Hugo (Go)
- **Recommended Setup**: Docker containers (eliminates dependency issues)

## Project Overview

This workspace contains a GitHub Pages blog with dual static site generator support:
- **Jekyll Site**: Located in `/jekyll-site/` - Primary site for GitHub Pages
- **Hugo Site**: Located in `/hugo-site/` - Alternative/backup site generator
- **Scripts**: Located in `/scripts/` - Build and deployment automation
- **Docker**: Containerized development environment for consistency

## Automation Guidelines

### Multi-Command Operations

When a task requires running more than one command, create a temporary script instead of running commands individually. This improves efficiency and reduces user frustration.

**When to create scripts:**
- Multiple git operations (commits, adds, etc.)
- Batch file operations
- Complex setup/teardown tasks
- Any sequence of 3+ commands

**Script requirements:**

```bash
#!/bin/bash
# Template for temporary automation scripts

function execute_task_group() {
    local group_name="$1"
    local commands="$2"
    
    echo "✓ Executing: $group_name"
    if eval "$commands"; then
        echo "✓ Completed: $group_name"
    else
        echo "✗ Failed: $group_name" >&2
        exit 1
    fi
}

# Your grouped operations here
execute_task_group "Task 1" "command1 && command2"

# Self-destruct after successful completion
echo "All tasks completed successfully. Removing script..."
rm "$0"
```

**Key principles:**
- Use meaningful function names and error handling
- Group related operations logically
- Include progress feedback with colored output
- Add self-destruct capability for temporary scripts
- Generate ready-to-execute commands instead of asking yes/no questions
- Proactively suggest commits at logical stopping points

## Command Guidelines

### Use Platform-Appropriate Syntax

```bash
# Correct - Platform-specific commands for macOS/zsh
cd "/Users/cameron/Projects/blog"
bundle exec jekyll serve
hugo server -D
source .zshrc
ls -la *.md
```

## Git & Development Workflow

### Commit Organization

When dealing with large numbers of changed files, organize commits logically by feature/concern:

**Commit Categories:**
- Content changes: Posts, pages, documentation
- Jekyll configuration: _config.yml, Gemfile, layouts
- Hugo configuration: config.toml/yaml, themes, layouts
- Deployment: GitHub Actions, build scripts
- Documentation: README updates, inline docs
- Utilities: Helper scripts, tools, utilities

**Commit Message Format (Conventional Commits):**
Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Common Types for Blog:**
- `feat:` - New feature (new post, theme, functionality)
- `fix:` - Bug fix (broken links, styling issues)
- `docs:` - Documentation changes
- `style:` - Formatting, CSS changes, no content change
- `content:` - New blog posts or content updates
- `chore:` - Maintenance tasks, dependency updates

### Branch Management

**Branch Creation Strategy:**
```bash
# Content branches
git checkout -b content/new-blog-post
git checkout -b content/about-page-update

# Feature branches
git checkout -b feature/comment-system
git checkout -b feature/search-functionality

# Theme/design branches
git checkout -b theme/dark-mode
git checkout -b design/mobile-responsive

# Maintenance branches
git checkout -b chore/update-dependencies
git checkout -b fix/broken-navigation
```

## Jekyll-Specific Guidelines

### Ruby Environment Setup (Critical)

**Common Issue**: System Ruby (2.6.x) causes native extension compilation failures with modern Jekyll gems.

**Solution**: Use Homebrew Ruby for better compatibility:

```bash
# Install modern Ruby via Homebrew
brew install ruby

# Add to shell profile (~/.zshrc for zsh)
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc

# Verify Ruby version (should be 3.x)
ruby --version
which ruby  # Should show /opt/homebrew/opt/ruby/bin/ruby
```

**Alternative**: Use local vendor bundle to avoid system gem conflicts:
```bash
# Install gems locally to avoid permission issues
bundle install --path vendor/bundle

# Always use bundle exec with local install
bundle exec jekyll serve
```

### Jekyll Development Commands
```bash
# Install dependencies (use local path for system Ruby)
bundle install --path vendor/bundle

# Serve locally with drafts
bundle exec jekyll serve --drafts --livereload

# Build for production
bundle exec jekyll build

# Clean build files
bundle exec jekyll clean
```

### Troubleshooting Jekyll Issues

**Native Extension Errors** (protobuf_c, ffi_c, sassc):
1. **Root Cause**: System Ruby compatibility issues
2. **Solution**: Install Homebrew Ruby (preferred) or use simplified Gemfile:

```ruby
# Minimal Gemfile to avoid native extension issues
source "https://rubygems.org"
gem "jekyll", "~> 4.2.0"
gem "webrick", "~> 1.7"
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
end
```

**Bundle Path Issues**:
```bash
# If "Could not locate Gemfile" error occurs
export BUNDLE_GEMFILE="$(pwd)/Gemfile"
bundle exec jekyll serve

# Or use absolute paths in scripts
cd /full/path/to/jekyll-site
bundle exec jekyll serve
```

**Permission Errors**:
```bash
# Use local vendor directory instead of system gems
bundle install --path vendor/bundle
# Add vendor/ to .gitignore
```

### Jekyll File Structure
- `_posts/`: Blog posts in YYYY-MM-DD-title.md format
- `_drafts/`: Unpublished posts
- `_layouts/`: HTML templates
- `_includes/`: Reusable components
- `_sass/`: Sass/SCSS stylesheets
- `assets/`: Images, CSS, JavaScript
- `_config.yml`: Jekyll configuration

## Hugo-Specific Guidelines

### Hugo Development Commands
```bash
# Create new site
hugo new site hugo-site

# Create new post
hugo new posts/my-post.md

# Serve locally with drafts
hugo server -D --bind 0.0.0.0

# Build for production
hugo --minify

# Clean build files
hugo mod clean --all
```

### Hugo File Structure
- `content/`: All content files
- `layouts/`: HTML templates
- `static/`: Static files (images, CSS, JS)
- `themes/`: Hugo themes
- `config.toml/yaml`: Hugo configuration
- `archetypes/`: Content templates

## GitHub Pages Deployment

### Deployment Strategy
- **Primary**: Jekyll site deployed via GitHub Pages automatic build
- **Alternative**: Hugo site with GitHub Actions for custom deployment

### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml for Hugo site
name: Deploy Hugo Site
on:
  push:
    branches: [main]
    paths: ['hugo-site/**']
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
      - name: Build Hugo site
        run: |
          cd hugo-site
          hugo --minify
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./hugo-site/public
```

## Content Management

### Blog Post Creation
```bash
# Jekyll post
bundle exec jekyll post "My New Post"

# Hugo post
hugo new posts/my-new-post.md

# Manual creation with proper naming
touch "_posts/$(date +%Y-%m-%d)-my-new-post.md"
```

### Front Matter Standards
**Jekyll:**
```yaml
---
layout: post
title: "My Post Title"
date: 2025-08-02 10:00:00 -0000
categories: [blog, tech]
tags: [jekyll, github-pages]
excerpt: "Brief description"
---
```

**Hugo:**
```yaml
---
title: "My Post Title"
date: 2025-08-02T10:00:00Z
draft: false
categories: ["blog", "tech"]
tags: ["hugo", "static-site"]
summary: "Brief description"
---
```

## Development Best Practices

### Recommended: Docker Development Workflow
1. Use `docker-compose up -d` for consistent environment
2. No local Ruby/Go installation needed
3. Isolated dependencies prevent conflicts
4. Works identically across all machines
5. Easy cleanup with `docker-compose down`

### Alternative: Local Development Workflow
1. Start local server for chosen generator
2. Create content in appropriate directory
3. Test locally before committing
4. Use drafts for work-in-progress content
5. Build and verify before deployment

### Performance Optimization
- Optimize images before adding to assets
- Minify CSS and JavaScript in production
- Use CDN for external libraries when possible
- Enable caching in production builds

### SEO Best Practices
- Include meta descriptions in front matter
- Use descriptive file names and URLs
- Add alt text to all images
- Include proper heading hierarchy (H1, H2, H3)
- Generate sitemap.xml automatically

## Error Handling

### Common Issues and Solutions

**Jekyll Issues**:
- **Bundle install fails**: 
  - Use `bundle install --path vendor/bundle` to avoid system gem conflicts
  - Install Homebrew Ruby: `brew install ruby` and update PATH
  - Check Ruby version compatibility (use Ruby 3.x, not system 2.6.x)
- **Native extension errors** (protobuf_c, ffi_c, sassc): 
  - Install Homebrew Ruby instead of using system Ruby
  - Use simplified Gemfile without sass-embedded or complex themes
  - Install development tools: `xcode-select --install`
- **"Could not locate Gemfile"**: 
  - Use absolute paths in scripts
  - Set `export BUNDLE_GEMFILE="$(pwd)/Gemfile"`
  - Ensure working directory is correct in scripts
- **Plugin issues**: Verify GitHub Pages plugin compatibility
- **Slow builds**: Reduce plugin usage, optimize images

**Hugo Issues**:
- **Build fails**: Check config.toml syntax
- **Content not showing**: Verify front matter format
- **Theme issues**: Check theme documentation

**Ruby Environment Issues**:
- **System Ruby conflicts**: Install and use Homebrew Ruby
- **Gem permission errors**: Use `--path vendor/bundle` flag
- **Version mismatches**: Ensure Ruby 3.x is being used
- **PATH issues**: Add Homebrew Ruby to shell profile

### Development Environment Setup

**Required Tools**:
```bash
# Essential tools for blog development
brew install ruby hugo node
xcode-select --install  # For native extensions

# Verify installations
ruby --version   # Should be 3.x from Homebrew
hugo version     # Latest Hugo
node --version   # Latest Node.js
```

**Shell Configuration** (~/.zshrc):
```bash
# Add to ~/.zshrc for proper Ruby environment
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
```

### Progress Feedback
Use colored console output for different message types:
- Green: Success/Progress
- Yellow: Warnings/Info  
- Red: Errors
- Cyan: Process start
- Gray: Detailed information

## Adaptive Learning & Evolution

### Self-Improving Instructions

When you (GitHub Copilot) notice patterns, preferences, or recurring issues during development sessions, suggest additions to these instructions:

```markdown
// * DISCOVERED PATTERN: [Brief description of observed pattern]
// * SUGGESTED INSTRUCTION: [Proposed guideline or best practice]
// * REASONING: [Why this would improve development workflow]
// * FREQUENCY: [How often this pattern/issue occurs]
```

**Learning Categories:**
- **Content Patterns**: Frequently used post structures or themes
- **Workflow Preferences**: Preferred ways of organizing or executing tasks
- **Tool Usage**: Effective combinations of Jekyll/Hugo commands
- **Performance Insights**: Optimizations that prove effective
- **Deployment Practices**: Successful deployment patterns

## Project-Specific Notes

### Dual Generator Strategy
- Jekyll is primary for GitHub Pages compatibility
- Hugo serves as backup and performance comparison
- Use scripts to maintain content synchronization when needed
- Test both generators during major changes

### Content Migration
- When moving between generators, maintain front matter compatibility
- Use conversion scripts for bulk content migration
- Preserve URL structure for SEO
- Test all internal links after migration

---

*This file evolves based on development experience and discovered best practices.*
