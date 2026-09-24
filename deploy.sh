#!/bin/sh
set -e

# Build
hugo

# Deploy to lo-tp.github.io
cd public
git add --all
git commit -m "deploy: $(date +%Y-%m-%d)" || exit 0
git push origin master
cd ..
