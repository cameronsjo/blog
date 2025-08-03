# Deployment Guide

This guide covers deploying your Jekyll and Hugo sites to GitHub Pages and other platforms.

## GitHub Pages Deployment

### Option 1: Jekyll (Recommended for GitHub Pages)

1. **Automatic Deployment**
   - Push to `main` branch
   - GitHub automatically builds and deploys Jekyll site
   - No additional configuration needed

2. **Custom Domain Setup**
   ```bash
   # Add CNAME file to jekyll-site/ directory
   echo "yourdomain.com" > jekyll-site/CNAME
   ```

3. **GitHub Pages Settings**
   - Go to repository Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` (after first deployment)
   - Folder: `/ (root)`

### Option 2: Hugo with GitHub Actions

1. **Enable GitHub Actions**
   - The workflow is already configured in `.github/workflows/deploy.yml`
   - Push to `main` branch triggers the build

2. **Configure Pages**
   - Go to repository Settings → Pages  
   - Source: Deploy from a branch
   - Branch: `hugo-pages`
   - Folder: `/ (root)`

3. **Custom Domain for Hugo**
   ```bash
   # Add static/CNAME file to hugo-site/
   echo "hugo.yourdomain.com" > hugo-site/static/CNAME
   ```

## Alternative Deployment Platforms

### Netlify

1. **Jekyll on Netlify**
   ```toml
   # netlify.toml for Jekyll
   [build]
     publish = "jekyll-site/_site"
     command = "cd jekyll-site && bundle exec jekyll build"

   [build.environment]
     RUBY_VERSION = "3.1"
   ```

2. **Hugo on Netlify**
   ```toml
   # netlify.toml for Hugo
   [build]
     publish = "hugo-site/public"
     command = "cd hugo-site && hugo --minify"

   [build.environment]
     HUGO_VERSION = "0.121.0"
   ```

### Vercel

1. **Create vercel.json**
   ```json
   {
     "builds": [
       {
         "src": "hugo-site/config.toml",
         "use": "@vercel/static-build",
         "config": {
           "distDir": "hugo-site/public"
         }
       }
     ],
     "build": {
       "env": {
         "HUGO_VERSION": "0.121.0"
       }
     }
   }
   ```

2. **Add build script to package.json**
   ```json
   {
     "scripts": {
       "vercel-build": "cd hugo-site && hugo --minify"
     }
   }
   ```

### Firebase Hosting

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init hosting
   ```

2. **Configure firebase.json**
   ```json
   {
     "hosting": {
       "public": "jekyll-site/_site",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

## Custom Deployment Scripts

### Deploy to Multiple Platforms

```bash
#!/bin/bash
# scripts/deploy-all.sh

echo "🚀 Deploying to all platforms..."

# Build both sites
./scripts/build-jekyll.sh
./scripts/build-hugo.sh

# Deploy Jekyll to GitHub Pages (automatic via push)
git add .
git commit -m "Deploy: $(date)"
git push origin main

# Deploy Hugo to Netlify (if configured)
if command -v netlify &> /dev/null; then
    cd hugo-site
    netlify deploy --prod --dir public
    cd ..
fi

# Deploy to Firebase (if configured)
if command -v firebase &> /dev/null; then
    firebase deploy --only hosting
fi

echo "✅ Deployment complete!"
```

### Preview Deployments

```bash
#!/bin/bash
# scripts/preview-deploy.sh

echo "🔍 Creating preview deployment..."

# Build sites
./scripts/build-jekyll.sh
./scripts/build-hugo.sh

# Create preview on Netlify
if command -v netlify &> /dev/null; then
    cd hugo-site
    netlify deploy --dir public
    cd ..
fi

# Or use Firebase preview
if command -v firebase &> /dev/null; then
    firebase hosting:channel:deploy preview
fi
```

## Environment Configuration

### Production Environment Variables

Create `.env.production` for production builds:

```bash
# Jekyll
JEKYLL_ENV=production
GITHUB_PAGES=true

# Hugo  
HUGO_ENV=production
HUGO_MINIFY=true
```

### Staging Environment

```bash
# .env.staging
JEKYLL_ENV=staging
HUGO_ENV=staging
BASEURL=/staging
```

## Performance Optimization

### Jekyll Optimization

1. **Enable production environment**
   ```yaml
   # _config.yml
   environment: production
   
   # Disable in production
   show_drafts: false
   incremental: false
   ```

2. **Compress images**
   ```bash
   # Install imagemin
   npm install -g imagemin-cli imagemin-webp
   
   # Compress images
   imagemin jekyll-site/assets/images/* --out-dir=jekyll-site/assets/images/compressed
   ```

### Hugo Optimization

1. **Enable minification**
   ```toml
   # config.toml
   [minify]
     disableCSS = false
     disableHTML = false
     disableJS = false
     disableJSON = false
     disableSVG = false
     disableXML = false
   ```

2. **Image processing**
   ```yaml
   # In Hugo templates
   {{ $image := .Resources.GetMatch "featured-image.*" }}
   {{ $image := $image.Resize "800x600 webp" }}
   ```

## Monitoring and Analytics

### GitHub Pages Analytics

1. **Google Analytics**
   ```html
   <!-- Add to Jekyll _includes/head.html -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
   <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag('js', new Date());
     gtag('config', 'GA_MEASUREMENT_ID');
   </script>
   ```

2. **Simple Analytics (Privacy-friendly)**
   ```html
   <script async defer src="https://scripts.simpleanalyticscdn.com/latest.js"></script>
   ```

### Performance Monitoring

1. **Web Vitals**
   ```html
   <script>
     import {getCLS, getFID, getFCP, getLCP, getTTFB} from 'web-vitals';
     
     getCLS(console.log);
     getFID(console.log);
     getFCP(console.log);
     getLCP(console.log);
     getTTFB(console.log);
   </script>
   ```

2. **Lighthouse CI**
   ```yaml
   # .github/workflows/lighthouse.yml
   name: Lighthouse CI
   on: [push]
   jobs:
     lighthouse:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: treosh/lighthouse-ci-action@v10
           with:
             configPath: './lighthouserc.json'
   ```

## Troubleshooting Deployment

### Common Issues

1. **Jekyll build fails on GitHub Pages**
   - Check for unsupported plugins
   - Verify Gemfile.lock is committed
   - Check Ruby version compatibility

2. **Hugo build fails**
   - Verify config.toml syntax
   - Check theme compatibility
   - Ensure git submodules are initialized

3. **Custom domain not working**
   - Verify CNAME file location
   - Check DNS settings
   - Wait for DNS propagation (up to 24 hours)

### Debugging

1. **Enable verbose logging**
   ```bash
   # Jekyll
   bundle exec jekyll build --verbose
   
   # Hugo
   hugo --verbose
   ```

2. **Test builds locally**
   ```bash
   # Test production builds
   JEKYLL_ENV=production bundle exec jekyll build
   HUGO_ENV=production hugo --minify
   ```

3. **Check deployment logs**
   - GitHub Actions: Go to Actions tab in repository
   - Netlify: Check deploy logs in Netlify dashboard
   - Vercel: Check function logs in Vercel dashboard

---

For more deployment options and advanced configurations, refer to:
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Jekyll Deployment Docs](https://jekyllrb.com/docs/deployment/)
- [Hugo Deployment Docs](https://gohugo.io/hosting-and-deployment/)
