# Blog Project - Dual Static Site Generator Setup

A GitHub Pages blog with both Jekyll and Hugo static site generators for maximum flexibility and performance comparison.

## Project Structure

```
blog/
├── .github/
│   ├── copilot-instructions.md    # Custom AI assistant instructions
│   └── workflows/                 # GitHub Actions (auto-created)
├── .vscode/
│   └── tasks.json                # VS Code build tasks
├── jekyll-site/                  # Primary Jekyll blog
│   ├── _config.yml
│   ├── Gemfile
│   ├── _posts/
│   ├── _layouts/
│   └── assets/
├── hugo-site/                    # Alternative Hugo blog
│   ├── config.toml
│   ├── content/
│   ├── layouts/
│   └── static/
├── scripts/                      # Build and deployment scripts
└── README.md                    # This file
```

## Quick Start

### Prerequisites

- **Ruby** (for Jekyll) - `brew install ruby`
- **Go** (for Hugo) - `brew install go`
- **Node.js** (for build tools) - `brew install node`

### Jekyll Setup

```bash
cd jekyll-site
gem install bundler jekyll
bundle install
bundle exec jekyll serve --livereload
```

Visit: http://localhost:4000

### Hugo Setup

```bash
cd hugo-site
brew install hugo
hugo server -D
```

Visit: http://localhost:1313

## Development Workflow

### Creating New Posts

**Jekyll:**
```bash
cd jekyll-site
bundle exec jekyll post "My New Post Title"
# Or manually create: _posts/YYYY-MM-DD-title.md
```

**Hugo:**
```bash
cd hugo-site
hugo new posts/my-new-post.md
```

### Local Development

1. Choose your preferred generator (Jekyll or Hugo)
2. Start the local development server
3. Write content in Markdown
4. Preview changes locally
5. Commit and push to deploy

### Deployment

- **Jekyll**: Automatic deployment via GitHub Pages
- **Hugo**: Custom GitHub Actions workflow (see `.github/workflows/`)

## Available Scripts

Run these from the project root:

- `./scripts/setup.sh` - Initial project setup
- `./scripts/build-jekyll.sh` - Build Jekyll site
- `./scripts/build-hugo.sh` - Build Hugo site
- `./scripts/sync-content.sh` - Sync content between generators
- `./scripts/deploy.sh` - Deploy to GitHub Pages

## Features

### Jekyll Features
- ✅ GitHub Pages compatible
- ✅ Liquid templating
- ✅ Sass/SCSS support
- ✅ Plugin ecosystem
- ✅ Automatic deployment

### Hugo Features
- ✅ Extremely fast builds
- ✅ Go templating
- ✅ Built-in image processing
- ✅ Multilingual support
- ✅ Advanced theming

## Configuration

### Jekyll Configuration
Main config: `jekyll-site/_config.yml`

### Hugo Configuration  
Main config: `hugo-site/config.toml`

## Themes

### Jekyll Themes
- Default: Minima theme
- Custom themes via Gemfile
- Theme development in `_layouts/` and `_sass/`

### Hugo Themes
- Install via git submodules or Hugo modules
- Custom themes in `hugo-site/themes/`

## Content Management

### Front Matter

**Jekyll Example:**
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

**Hugo Example:**
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

## Deployment Options

### Option 1: Jekyll on GitHub Pages (Default)
- Push to `main` branch
- GitHub automatically builds and deploys Jekyll site
- Uses `jekyll-site/` as source

### Option 2: Hugo with GitHub Actions
- Custom workflow builds Hugo site
- Deploys to `gh-pages` branch
- Requires manual activation

### Option 3: Dual Deployment
- Jekyll serves main domain
- Hugo serves subdomain or different repository

## Performance Comparison

| Feature | Jekyll | Hugo |
|---------|--------|------|
| Build Speed | ~2-5s | ~200ms |
| Plugin Ecosystem | Extensive | Growing |
| Learning Curve | Moderate | Moderate |
| GitHub Pages | Native | Custom Actions |
| Templating | Liquid | Go Templates |

## Troubleshooting

### Common Issues

**Jekyll:**
- `bundle install` fails → Check Ruby version
- Plugins not working → Verify GitHub Pages compatibility
- Slow builds → Reduce plugin usage, optimize images

**Hugo:**
- Build fails → Check config.toml syntax
- Content not showing → Verify front matter format
- Theme issues → Check theme documentation

### Getting Help

1. Check the official documentation:
   - [Jekyll Docs](https://jekyllrb.com/docs/)
   - [Hugo Docs](https://gohugo.io/documentation/)
2. Search GitHub issues in respective repositories
3. Ask in community forums or Discord servers

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Hugo Documentation](https://gohugo.io/documentation/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Markdown Guide](https://www.markdownguide.org/)
- [Liquid Template Language](https://shopify.github.io/liquid/)
- [Go Template Language](https://golang.org/pkg/text/template/)

---

**Note**: This project uses dual static site generators for comparison and flexibility. Choose the one that best fits your needs, or use both for different purposes.
