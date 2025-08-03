# Docker Setup for Blog Development

## Why Docker is Better for This Project

### Problems Docker Solves:
1. **Ruby Version Conflicts**: No more system Ruby vs Homebrew Ruby issues
2. **Native Extension Errors**: No more protobuf_c, ffi_c, sassc compilation failures  
3. **Dependency Hell**: Isolated gem environments
4. **Platform Differences**: Same environment on macOS, Linux, Windows
5. **Quick Setup**: One command gets everything running

### Before Docker (what we just experienced):
```bash
# Install Homebrew Ruby
brew install ruby

# Update PATH in ~/.zshrc
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Add missing Ruby 3.4+ gems
gem "csv" "logger" "base64" "bigdecimal" "ostruct" "psych"

# Debug bundle path issues
export BUNDLE_GEMFILE="/path/to/Gemfile"

# Still might fail with native extensions...
```

### With Docker (effortless):
```bash
# One command starts everything
docker-compose up -d

# Jekyll: http://localhost:4000
# Hugo: http://localhost:1313
# No Ruby installation needed!
```

## Quick Docker Installation

### macOS:
```bash
# Install Docker Desktop
brew install --cask docker

# Or download from https://www.docker.com/products/docker-desktop
```

### Alternative - Use GitHub Codespaces:
If you don't want to install Docker locally, you can run this entire project in GitHub Codespaces with Docker pre-installed.

## Docker Commands

```bash
# Start both Jekyll and Hugo
docker-compose up -d

# View logs
docker-compose logs -f

# Stop everything
docker-compose down

# Rebuild containers (after Dockerfile changes)
docker-compose build --no-cache

# Shell into Jekyll container
docker-compose exec jekyll sh

# Shell into Hugo container  
docker-compose exec hugo sh
```

## Benefits vs Local Development

| Aspect | Local Setup | Docker Setup |
|--------|-------------|--------------|
| **Setup Time** | 30+ mins (with troubleshooting) | 2 minutes |
| **Ruby Issues** | Frequent conflicts | None |
| **Cross-platform** | Different on each OS | Identical everywhere |
| **New Contributor** | Must install Ruby/Go | Just needs Docker |
| **CI/CD** | Environment drift | Exact same container |
| **Cleanup** | Gems scattered in system | `docker-compose down` |

## Current Status

Your blog is working perfectly with the local Ruby setup we configured. Docker would make it even more reliable and easier for future development or collaboration.

To switch to Docker:
1. Install Docker Desktop
2. Run `docker-compose up -d`
3. Enjoy zero-configuration development!
