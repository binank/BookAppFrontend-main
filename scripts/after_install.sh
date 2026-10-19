#!/bin/bash
set -e

cd /app

# Make sure devDependencies (eslint plugins etc.) are installed
export NODE_ENV=development

# Clean stale state from previous deployments
rm -rf node_modules build

# Install dependencies (npm ci if a lockfile exists, otherwise npm install)
if [ -f package-lock.json ]; then
  npm ci --include=dev
else
  npm install --include=dev
fi

# Build (ESLint plugin disabled to avoid the "jest/globals is unknown" error;
# openssl legacy provider flag is for Node 17+ / Node 18)
DISABLE_ESLINT_PLUGIN=true NODE_OPTIONS=--openssl-legacy-provider npm run build

# Deploy static files
mkdir -p /var/www/html
rm -rf /var/www/html/*
cp -r build/* /var/www/html/

# Install PM2 only if it is not already installed
if ! command -v pm2 >/dev/null 2>&1; then
  npm install pm2 -g
fi
