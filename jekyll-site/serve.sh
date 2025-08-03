#!/bin/bash
# Jekyll server script

cd "$(dirname "$0")"
export BUNDLE_GEMFILE="$PWD/Gemfile"
echo "Starting Jekyll server from: $PWD"
echo "Using Gemfile: $BUNDLE_GEMFILE"

bundle exec jekyll serve --livereload --port 4000
