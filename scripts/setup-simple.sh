#!/bin/bash
# Simplified Blog Project Setup Script
# Sets up Jekyll and Hugo without system gem modifications

set -e

echo "🚀 Setting up Blog Project with Jekyll + Hugo (Simplified)"

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function print_status() {
    echo -e "${CYAN}✓ $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Setup Jekyll site structure
echo -e "${BLUE}🔧 Setting up Jekyll site structure...${NC}"

cd jekyll-site

# Create basic Jekyll structure
mkdir -p _posts _drafts _layouts _includes _sass assets/css assets/js assets/images

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

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]
EOF

print_status "Created Jekyll Gemfile"

# Create Jekyll config
cat > _config.yml << 'EOF'
title: My Blog
email: your-email@example.com
description: >-
  A modern blog built with Jekyll and Hugo static site generators.
  Write an awesome description for your new site here.
baseurl: ""
url: "https://username.github.io"

markdown: kramdown
highlighter: rouge
theme: minima
plugins:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-seo-tag

permalink: /:year/:month/:day/:title/

exclude:
  - .sass-cache/
  - .jekyll-cache/
  - gemfiles/
  - Gemfile
  - Gemfile.lock
  - node_modules/
  - vendor/

collections:
  posts:
    output: true

defaults:
  - scope:
      path: ""
      type: "posts"
    values:
      layout: "post"
      author: "Your Name"
EOF

print_status "Created Jekyll configuration"

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

## Getting Started

To add new posts, simply add a file in the `_posts` directory that follows the convention `_posts/YYYY-MM-DD-name-of-post.ext` and includes the necessary front matter.

### Code Highlighting

Jekyll offers powerful support for code snippets:

```ruby
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Jekyll')
#=> prints 'Hi, Jekyll' to STDOUT.
```

Check out the [Jekyll docs](https://jekyllrb.com/docs/home) for more info.
EOF

print_status "Created sample Jekyll post"

# Create basic layout
mkdir -p _layouts
cat > _layouts/default.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ page.title | default: site.title }}</title>
    <link rel="stylesheet" href="{{ '/assets/css/style.css' | relative_url }}">
</head>
<body>
    <header>
        <h1><a href="{{ '/' | relative_url }}">{{ site.title }}</a></h1>
        <p>{{ site.description }}</p>
    </header>
    
    <main>
        {{ content }}
    </main>
    
    <footer>
        <p>&copy; {{ 'now' | date: "%Y" }} {{ site.author | default: "Your Name" }}</p>
    </footer>
</body>
</html>
EOF

cat > _layouts/post.html << 'EOF'
---
layout: default
---

<article>
    <header>
        <h1>{{ page.title }}</h1>
        <time datetime="{{ page.date | date_to_xmlschema }}">
            {{ page.date | date: "%B %d, %Y" }}
        </time>
    </header>
    
    {{ content }}
    
    <footer>
        {% if page.tags %}
            <p>Tags: 
            {% for tag in page.tags %}
                <span class="tag">{{ tag }}</span>
            {% endfor %}
            </p>
        {% endif %}
    </footer>
</article>
EOF

# Create basic CSS
cat > assets/css/style.css << 'EOF'
/* Basic styling for Jekyll blog */
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    color: #333;
}

header h1 a {
    text-decoration: none;
    color: #333;
}

header h1 a:hover {
    color: #007acc;
}

main {
    margin: 40px 0;
}

.tag {
    background: #f1f1f1;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 0.9em;
    margin-right: 5px;
}

pre {
    background: #f4f4f4;
    padding: 15px;
    border-radius: 5px;
    overflow-x: auto;
}

footer {
    text-align: center;
    padding-top: 20px;
    border-top: 1px solid #eee;
    color: #666;
}
EOF

# Create index page
cat > index.md << 'EOF'
---
layout: default
---

# Welcome to My Blog

This blog is built with Jekyll and Hugo static site generators for maximum flexibility.

## Recent Posts

{% for post in site.posts limit:5 %}
  <article>
    <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
    <time>{{ post.date | date: "%B %d, %Y" }}</time>
    <p>{{ post.excerpt }}</p>
  </article>
{% endfor %}

[View all posts →](/posts/)
EOF

print_success "Jekyll site structure created!"

cd ..

# Setup Hugo
echo -e "${BLUE}🔧 Setting up Hugo site...${NC}"

cd hugo-site

# Initialize Hugo site if not already done
if [ ! -f "config.toml" ]; then
    hugo new site . --force
fi

# Create Hugo config
cat > config.toml << 'EOF'
baseURL = 'https://username.github.io'
languageCode = 'en-us'
title = 'My Hugo Blog'

[params]
  author = "Your Name"
  description = "A modern blog built with Jekyll and Hugo static site generators"
  
[markup]
  [markup.highlight]
    style = "github"
    lineNos = true

[menu]
  [[menu.main]]
    name = "Home"
    url = "/"
    weight = 10
  
  [[menu.main]]
    name = "Posts"
    url = "/posts/"
    weight = 20
  
  [[menu.main]]
    name = "About"
    url = "/about/"
    weight = 30
EOF

print_status "Created Hugo configuration"

# Create sample content
hugo new posts/welcome-to-hugo.md

cat > content/posts/welcome-to-hugo.md << 'EOF'
---
title: "Welcome to Hugo!"
date: 2025-08-02T10:00:00Z
draft: false
tags: ["hugo", "blog", "getting-started"]
categories: ["blog"]
---

# Welcome to Your Hugo Blog!

You'll find this post in your `content/posts` directory. Hugo builds sites incredibly fast and offers great flexibility.

## Getting Started

To add new posts, simply add a file in the `content/posts` directory with proper front matter.

### Code Highlighting

Hugo offers excellent code highlighting:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Hugo!")
}
```

Check out the [Hugo docs](https://gohugo.io/documentation/) for more information.
EOF

# Create about page
cat > content/about.md << 'EOF'
---
title: "About"
date: 2025-08-02T10:00:00Z
draft: false
---

# About This Blog

This is a dual-generator blog built with both Jekyll and Hugo static site generators.

## Why Dual Generators?

- Performance comparison
- Backup options for content delivery  
- Learning opportunities with different systems
- Flexibility in deployment strategies
EOF

# Create basic theme structure
mkdir -p layouts/_default themes static

cat > layouts/_default/baseof.html << 'EOF'
<!DOCTYPE html>
<html lang="{{ .Site.LanguageCode }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ block "title" . }}{{ .Site.Title }}{{ end }}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        header h1 a { text-decoration: none; color: #333; }
        header h1 a:hover { color: #007acc; }
        main { margin: 40px 0; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
        footer { text-align: center; padding-top: 20px; border-top: 1px solid #eee; color: #666; }
    </style>
</head>
<body>
    <header>
        <h1><a href="{{ .Site.BaseURL }}">{{ .Site.Title }}</a></h1>
        <p>{{ .Site.Params.description }}</p>
    </header>
    
    <main>
        {{ block "main" . }}{{ end }}
    </main>
    
    <footer>
        <p>&copy; {{ now.Format "2006" }} {{ .Site.Params.author }}</p>
    </footer>
</body>
</html>
EOF

cat > layouts/_default/single.html << 'EOF'
{{ define "title" }}{{ .Title }} | {{ .Site.Title }}{{ end }}
{{ define "main" }}
<article>
    <header>
        <h1>{{ .Title }}</h1>
        <time datetime="{{ .Date.Format "2006-01-02" }}">
            {{ .Date.Format "January 2, 2006" }}
        </time>
    </header>
    
    {{ .Content }}
</article>
{{ end }}
EOF

cat > layouts/_default/list.html << 'EOF'
{{ define "main" }}
<h1>{{ .Title }}</h1>

{{ range .Pages }}
<article>
    <h3><a href="{{ .RelPermalink }}">{{ .Title }}</a></h3>
    <time>{{ .Date.Format "January 2, 2006" }}</time>
    {{ if .Summary }}<p>{{ .Summary }}</p>{{ end }}
</article>
{{ end }}
{{ end }}
EOF

cat > layouts/index.html << 'EOF'
{{ define "main" }}
<h1>Welcome to My Hugo Blog</h1>

<p>This blog is built with Jekyll and Hugo static site generators for maximum flexibility.</p>

<h2>Recent Posts</h2>

{{ range first 5 .Site.RegularPages }}
<article>
    <h3><a href="{{ .RelPermalink }}">{{ .Title }}</a></h3>
    <time>{{ .Date.Format "January 2, 2006" }}</time>
    {{ if .Summary }}<p>{{ .Summary }}</p>{{ end }}
</article>
{{ end }}

<p><a href="/posts/">View all posts →</a></p>
{{ end }}
EOF

print_success "Hugo site structure created!"

cd ..

print_success "🎉 Blog project setup complete!"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Install Jekyll dependencies:"
echo -e "   ${CYAN}cd jekyll-site && bundle install${NC}"
echo
echo "2. Start development servers:"
echo -e "   Jekyll: ${CYAN}cd jekyll-site && bundle exec jekyll serve${NC}"
echo -e "   Hugo: ${CYAN}cd hugo-site && hugo server -D${NC}"
echo
echo "3. Or use the provided scripts:"
echo -e "   ${CYAN}./scripts/serve-jekyll.sh${NC}"
echo -e "   ${CYAN}./scripts/serve-hugo.sh${NC}"
echo
echo "4. Create new posts using Hugo's command:"
echo -e "   ${CYAN}cd hugo-site && hugo new posts/my-post.md${NC}"
echo
echo -e "${BLUE}Happy blogging! 📝${NC}"

# Self-destruct
rm "$0"
