#!/bin/bash
# Blog Project Setup Script
# Initializes both Jekyll and Hugo static site generators

set -e

echo "🚀 Setting up Blog Project with Jekyll + Hugo"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function print_status() {
    echo -e "${CYAN}✓ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v ruby &> /dev/null; then
    print_error "Ruby not found. Install with: brew install ruby"
    exit 1
fi
print_status "Ruby found: $(ruby --version)"

# Check if we're using system Ruby and suggest Homebrew Ruby
if [[ "$(which ruby)" == "/usr/bin/ruby" ]]; then
    print_warning "Using system Ruby. Installing Homebrew Ruby for better gem management..."
    if command -v brew &> /dev/null; then
        brew install ruby
        # Add Homebrew Ruby to PATH
        export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
        export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
        print_status "Homebrew Ruby installed and PATH updated"
    else
        print_error "Homebrew not found. Please install Homebrew or use rbenv/rvm for Ruby management"
        exit 1
    fi
fi

if ! command -v gem &> /dev/null; then
    print_error "RubyGems not found. Please install Ruby properly."
    exit 1
fi
print_status "RubyGems found: $(gem --version)"

if ! command -v hugo &> /dev/null; then
    print_warning "Hugo not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install hugo
        print_status "Hugo installed: $(hugo version)"
    else
        print_error "Homebrew not found. Please install Hugo manually: https://gohugo.io/installation/"
        exit 1
    fi
else
    print_status "Hugo found: $(hugo version)"
fi

if ! command -v node &> /dev/null; then
    print_warning "Node.js not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install node
        print_status "Node.js installed: $(node --version)"
    else
        print_error "Homebrew not found. Please install Node.js manually"
        exit 1
    fi
else
    print_status "Node.js found: $(node --version)"
fi

# Setup Jekyll
echo -e "${BLUE}🔧 Setting up Jekyll site...${NC}"

if ! gem list bundler -i &> /dev/null; then
    print_status "Installing Bundler..."
    gem install --user-install bundler
fi

if ! gem list jekyll -i &> /dev/null; then
    print_status "Installing Jekyll..."
    gem install --user-install jekyll
fi

cd jekyll-site

# Create Gemfile
cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "jekyll", "~> 4.3.0"
gem "minima", "~> 2.5"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]
EOF

print_status "Created Gemfile"

# Create Jekyll config
cat > _config.yml << 'EOF'
title: My Blog
email: your-email@example.com
description: >-
  A modern blog built with Jekyll and Hugo static site generators.
  Write an awesome description for your new site here.
baseurl: ""
url: "https://username.github.io"

# Build settings
markdown: kramdown
highlighter: rouge
theme: minima
plugins:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-seo-tag

# Permalink structure
permalink: /:year/:month/:day/:title/

# Pagination
paginate: 5
paginate_path: "/page:num/"

# Exclude from processing
exclude:
  - .sass-cache/
  - .jekyll-cache/
  - gemfiles/
  - Gemfile
  - Gemfile.lock
  - node_modules/
  - vendor/bundle/
  - vendor/cache/
  - vendor/gems/
  - vendor/ruby/

# Collections
collections:
  posts:
    output: true
    permalink: /:collection/:year/:month/:day/:title/

# Defaults
defaults:
  - scope:
      path: ""
      type: "posts"
    values:
      layout: "post"
      author: "Your Name"
EOF

print_status "Created Jekyll configuration"

# Create initial directories
mkdir -p _posts _drafts _layouts _includes _sass assets/css assets/js assets/images

# Create sample post
cat > "_posts/$(date +%Y-%m-%d)-welcome-to-jekyll.md" << 'EOF'
---
layout: post
title:  "Welcome to Jekyll!"
date:   2025-08-02 10:00:00 -0000
categories: jekyll update
tags: [jekyll, blog, getting-started]
excerpt: "Welcome to your new Jekyll blog! This is your first post."
---

# Welcome to Your Jekyll Blog!

You'll find this post in your `_posts` directory. Go ahead and edit it and re-build the site to see your changes.

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-title.MARKUP`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `MARKUP` is the file extension representing the format used in the file.

## Getting Started

To add new posts, simply add a file in the `_posts` directory that follows the convention `_posts/YYYY-MM-DD-name-of-post.ext` and includes the necessary front matter. Take a look at the source for this post to get an idea about how it works.

### Code Highlighting

Jekyll also offers powerful support for code snippets:

```ruby
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Jekyll')
#=> prints 'Hi, Jekyll' to STDOUT.
```

Check out the [Jekyll docs][jekyll-docs] for more info on how to get the most out of Jekyll.

[jekyll-docs]: https://jekyllrb.com/docs/home
EOF

print_status "Created sample Jekyll post"

# Install Jekyll dependencies
print_status "Installing Jekyll dependencies..."
bundle install

print_success "Jekyll site setup complete!"

cd ..

# Setup Hugo
echo -e "${BLUE}🔧 Setting up Hugo site...${NC}"

cd hugo-site

# Initialize Hugo site
hugo new site . --force

# Create Hugo config
cat > config.toml << 'EOF'
baseURL = 'https://username.github.io'
languageCode = 'en-us'
title = 'My Hugo Blog'
theme = 'PaperMod'

[params]
  author = "Your Name"
  description = "A modern blog built with Jekyll and Hugo static site generators"
  keywords = ["blog", "hugo", "static-site"]
  
  # Theme specific params
  ShowReadingTime = true
  ShowPostNavLinks = true
  ShowBreadCrumbs = true
  ShowCodeCopyButtons = true
  ShowWordCount = true
  ShowRssButtonInSectionTermList = true
  UseHugoToc = true
  disableSpecial1stPost = false
  disableScrollToTop = false
  comments = false
  hidemeta = false
  hideSummary = false
  showtoc = false
  tocopen = false

[menu]
  [[menu.main]]
    identifier = "home"
    name = "Home"
    url = "/"
    weight = 10
  
  [[menu.main]]
    identifier = "posts"
    name = "Posts"
    url = "/posts/"
    weight = 20
  
  [[menu.main]]
    identifier = "about"
    name = "About"
    url = "/about/"
    weight = 30

[markup]
  [markup.highlight]
    noClasses = false
    codeFences = true
    guessSyntax = true
    lineNos = true
    style = "github"

[outputs]
  home = ["HTML", "RSS", "JSON"]
EOF

print_status "Created Hugo configuration"

# Create sample content
hugo new posts/welcome-to-hugo.md

# Update the sample post
cat > content/posts/welcome-to-hugo.md << 'EOF'
---
title: "Welcome to Hugo!"
date: 2025-08-02T10:00:00Z
draft: false
tags: ["hugo", "blog", "getting-started"]
categories: ["blog"]
author: "Your Name"
summary: "Welcome to your new Hugo blog! This is your first post."
cover:
    image: ""
    alt: ""
    caption: ""
    relative: false
---

# Welcome to Your Hugo Blog!

You'll find this post in your `content/posts` directory. Go ahead and edit it and re-build the site to see your changes.

Hugo requires blog post files to be placed in the `content` directory with proper front matter.

## Getting Started

To add new posts, simply add a file in the `content/posts` directory and include the necessary front matter. Take a look at the source for this post to get an idea about how it works.

### Code Highlighting

Hugo also offers powerful support for code snippets:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Hugo!")
}
```

Check out the [Hugo docs](https://gohugo.io/documentation/) for more info on how to get the most out of Hugo.

## Features

Hugo offers many great features:

- **Fast builds** - Hugo is written in Go and builds sites incredibly fast
- **Flexible** - Hugo is flexible enough to fit any project
- **Easy to use** - Hugo has a gentle learning curve
- **Open source** - Hugo is completely open source
EOF

# Create about page
hugo new about.md
cat > content/about.md << 'EOF'
---
title: "About"
date: 2025-08-02T10:00:00Z
draft: false
---

# About This Blog

This is a dual-generator blog built with both Jekyll and Hugo static site generators. This allows for:

- Performance comparison between generators
- Backup options for content delivery
- Learning opportunities with different templating systems
- Flexibility in deployment strategies

## Why Dual Generators?

Jekyll and Hugo each have their strengths:

**Jekyll**
- Native GitHub Pages support
- Mature plugin ecosystem
- Liquid templating language
- Ruby-based

**Hugo** 
- Extremely fast build times
- Go templating language
- Built-in image processing
- Growing theme ecosystem

This setup allows you to choose the best tool for each situation or even run both simultaneously.
EOF

print_status "Created Hugo content"

# Install a theme (PaperMod)
print_status "Installing Hugo theme..."
git init
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
git submodule update --init --recursive

print_success "Hugo site setup complete!"

cd ..

# Create build scripts
echo -e "${BLUE}📝 Creating build scripts...${NC}"

# Jekyll build script
cat > scripts/build-jekyll.sh << 'EOF'
#!/bin/bash
# Build Jekyll site

echo "🔨 Building Jekyll site..."

cd jekyll-site

# Clean previous build
bundle exec jekyll clean

# Build site
bundle exec jekyll build

echo "✅ Jekyll build complete!"
echo "Site built in: jekyll-site/_site/"
EOF

chmod +x scripts/build-jekyll.sh

# Hugo build script
cat > scripts/build-hugo.sh << 'EOF'
#!/bin/bash
# Build Hugo site

echo "🔨 Building Hugo site..."

cd hugo-site

# Clean previous build
hugo mod clean --all

# Build site
hugo --minify

echo "✅ Hugo build complete!"
echo "Site built in: hugo-site/public/"
EOF

chmod +x scripts/build-hugo.sh

# Serve Jekyll script
cat > scripts/serve-jekyll.sh << 'EOF'
#!/bin/bash
# Serve Jekyll site locally

echo "🚀 Starting Jekyll development server..."

cd jekyll-site
bundle exec jekyll serve --livereload --drafts --open-url

echo "Jekyll server stopped."
EOF

chmod +x scripts/serve-jekyll.sh

# Serve Hugo script
cat > scripts/serve-hugo.sh << 'EOF'
#!/bin/bash
# Serve Hugo site locally

echo "🚀 Starting Hugo development server..."

cd hugo-site
hugo server -D --bind 0.0.0.0 --baseURL http://localhost

echo "Hugo server stopped."
EOF

chmod +x scripts/serve-hugo.sh

# Content sync script
cat > scripts/sync-content.sh << 'EOF'
#!/bin/bash
# Sync content between Jekyll and Hugo

echo "🔄 Syncing content between Jekyll and Hugo..."

# This is a placeholder for content synchronization
# You would implement logic here to convert between
# Jekyll and Hugo front matter formats and file structures

echo "⚠️  Content sync not yet implemented"
echo "Manually copy and convert content between:"
echo "  - jekyll-site/_posts/ ↔ hugo-site/content/posts/"
echo "  - Adjust front matter formats as needed"
EOF

chmod +x scripts/sync-content.sh

print_status "Created build scripts"

# Create VS Code tasks
echo -e "${BLUE}⚙️ Creating VS Code tasks...${NC}"

cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Jekyll: Serve",
            "type": "shell",
            "command": "./scripts/serve-jekyll.sh",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            },
            "isBackground": true,
            "problemMatcher": [],
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "Hugo: Serve",
            "type": "shell",
            "command": "./scripts/serve-hugo.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            },
            "isBackground": true,
            "problemMatcher": [],
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "Jekyll: Build",
            "type": "shell",
            "command": "./scripts/build-jekyll.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "Hugo: Build",
            "type": "shell",
            "command": "./scripts/build-hugo.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "Jekyll: New Post",
            "type": "shell",
            "command": "bundle",
            "args": ["exec", "jekyll", "post", "${input:postTitle}"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "options": {
                "cwd": "${workspaceFolder}/jekyll-site"
            }
        },
        {
            "label": "Hugo: New Post",
            "type": "shell",
            "command": "hugo",
            "args": ["new", "posts/${input:postSlug}.md"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "options": {
                "cwd": "${workspaceFolder}/hugo-site"
            }
        }
    ],
    "inputs": [
        {
            "id": "postTitle",
            "description": "Post title",
            "default": "My New Post",
            "type": "promptString"
        },
        {
            "id": "postSlug",
            "description": "Post slug (filename)",
            "default": "my-new-post",
            "type": "promptString"
        }
    ]
}
EOF

print_status "Created VS Code tasks"

# Create .gitignore
cat > .gitignore << 'EOF'
# Jekyll
jekyll-site/_site/
jekyll-site/.sass-cache/
jekyll-site/.jekyll-cache/
jekyll-site/.jekyll-metadata
jekyll-site/vendor/

# Hugo
hugo-site/public/
hugo-site/resources/_gen/

# Dependencies
node_modules/
.bundle/
vendor/

# Logs
*.log
npm-debug.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/settings.json
.idea/
*.swp
*.swo

# Temporary files
*.tmp
*.temp
.tmp/

# Build artifacts
dist/
build/

# Environment
.env
.env.local
.env.production

# Cache
.cache/
EOF

print_status "Created .gitignore"

# Final instructions
echo -e "${GREEN}🎉 Blog project setup complete!${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Start Jekyll development server:"
echo -e "   ${CYAN}./scripts/serve-jekyll.sh${NC}"
echo "   or use VS Code task: Ctrl/Cmd+Shift+P → 'Tasks: Run Task' → 'Jekyll: Serve'"
echo
echo "2. Start Hugo development server:"
echo -e "   ${CYAN}./scripts/serve-hugo.sh${NC}"
echo "   or use VS Code task: Ctrl/Cmd+Shift+P → 'Tasks: Run Task' → 'Hugo: Serve'"
echo
echo "3. Create new posts:"
echo -e "   Jekyll: ${CYAN}cd jekyll-site && bundle exec jekyll post \"Post Title\"${NC}"
echo -e "   Hugo: ${CYAN}cd hugo-site && hugo new posts/post-slug.md${NC}"
echo
echo "4. Customize your sites:"
echo -e "   Jekyll config: ${CYAN}jekyll-site/_config.yml${NC}"
echo -e "   Hugo config: ${CYAN}hugo-site/config.toml${NC}"
echo
echo "5. Set up GitHub repository:"
echo -e "   ${CYAN}git init && git add . && git commit -m \"Initial blog setup\"${NC}"
echo
echo -e "${BLUE}Happy blogging! 📝${NC}"

# Self-destruct
rm "$0"
