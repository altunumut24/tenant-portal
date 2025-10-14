#!/usr/bin/env bash
set -euo pipefail

# Tenant Portal - DigitalOcean Deployment Script
# This script helps deploy the portal to DigitalOcean App Platform

echo "========================================"
echo "Tenant Portal - DigitalOcean Deployment"
echo "========================================"
echo ""

# Config
APP_SPEC="${APP_SPEC:-.doctl-app.yaml}"
APP_NAME="tenant-portal"

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "ERROR: doctl CLI is not installed."
    echo ""
    echo "Please install it first:"
    echo "  macOS: brew install doctl"
    echo "  Linux: snap install doctl"
    echo ""
    echo "Then authenticate:"
    echo "  doctl auth init"
    exit 1
fi

# Check if authenticated
if ! doctl account get &> /dev/null; then
    echo "ERROR: Not authenticated with DigitalOcean."
    echo ""
    echo "Please authenticate first:"
    echo "  doctl auth init"
    exit 1
fi

# Check if app spec file exists
if [ ! -f "${APP_SPEC}" ]; then
    echo "ERROR: App spec file not found: ${APP_SPEC}"
    exit 1
fi

echo "Current DigitalOcean account:"
doctl account get
echo ""

echo "NOTE: Before deploying, make sure you've:"
echo "  1. Pushed code to GitHub"
echo "  2. Updated .doctl-app.yaml with your GitHub repo details"
echo ""
read -p "Have you completed these steps? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please complete the setup first:"
    echo ""
    echo "  # Initialize git and push to GitHub"
    echo "  git init"
    echo "  git add ."
    echo "  git commit -m 'Initial commit: Tenant portal'"
    echo "  gh repo create tenant-portal --public --source=. --remote=origin --push"
    echo ""
    echo "  # Or if repo already exists:"
    echo "  git remote add origin https://github.com/YOUR_USERNAME/tenant-portal.git"
    echo "  git push -u origin main"
    echo ""
    exit 0
fi

echo ""
echo "Checking for existing apps..."
EXISTING_APP=$(doctl apps list --format ID,Spec.Name --no-header | grep "${APP_NAME}" | awk '{print $1}' || true)

if [ -z "${EXISTING_APP}" ]; then
    echo ""
    echo "No existing app found. Creating new app '${APP_NAME}'..."
    echo ""
    read -p "Do you want to create a new app? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating app..."
        doctl apps create --spec "${APP_SPEC}"
        
        echo ""
        echo "✓ App created successfully!"
        echo ""
        echo "Monitor deployment:"
        echo "  doctl apps list"
        echo ""
        echo "View in browser:"
        echo "  https://cloud.digitalocean.com/apps"
    else
        echo "Deployment cancelled."
        exit 0
    fi
else
    echo "Found existing app: ${EXISTING_APP}"
    echo ""
    echo "Updating app with new configuration..."
    read -p "Do you want to update the existing app? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Updating app..."
        doctl apps update "${EXISTING_APP}" --spec "${APP_SPEC}"
        
        echo ""
        echo "✓ App updated successfully!"
    else
        echo "Deployment cancelled."
        exit 0
    fi
fi

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Wait for build and deployment (3-5 minutes)"
echo "2. Visit: https://cloud.digitalocean.com/apps"
echo "3. Configure custom domain if needed"
echo "4. Test the portal at the provided URL"
echo ""

