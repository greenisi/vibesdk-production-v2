#!/bin/bash

# Deploy Templates to R2 Bucket
# This script deploys all templates to the R2 bucket for the Vibe SDK

set -euo pipefail

echo "🚀 Deploying Templates to R2 Bucket"
echo "===================================="
echo ""

# Check if required environment variables are set
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
    echo "❌ Error: CLOUDFLARE_API_TOKEN environment variable is not set"
    echo ""
    echo "Please set it by running:"
    echo "  export CLOUDFLARE_API_TOKEN='your_token_here'"
    echo ""
    echo "Get your API token from: https://dash.cloudflare.com/profile/api-tokens"
    exit 1
fi

if [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
    echo "❌ Error: CLOUDFLARE_ACCOUNT_ID environment variable is not set"
    echo ""
    echo "Please set it by running:"
    echo "  export CLOUDFLARE_ACCOUNT_ID='your_account_id_here'"
    echo ""
    echo "Find your Account ID at: https://dash.cloudflare.com/"
    exit 1
fi

# Set R2 bucket name
export R2_BUCKET_NAME="${R2_BUCKET_NAME:-vibesdk-templates}"
export LOCAL_R2="${LOCAL_R2:-false}"

echo "✅ Configuration:"
echo "   R2 Bucket: $R2_BUCKET_NAME"
echo "   Local R2: $LOCAL_R2"
echo "   Account ID: ${CLOUDFLARE_ACCOUNT_ID:0:10}..."
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Error: Wrangler CLI is not installed"
    echo ""
    echo "Please install it by running:"
    echo "  npm install -g wrangler"
    exit 1
fi

echo "✅ Wrangler CLI found: $(wrangler --version)"
echo ""

# Navigate to templates directory
if [ ! -d "templates" ]; then
    echo "❌ Error: templates directory not found"
    echo "   Please run this script from the project root directory"
    exit 1
fi

cd templates

# Check if deploy script exists
if [ ! -f "deploy_templates.sh" ]; then
    echo "❌ Error: deploy_templates.sh not found in templates directory"
    exit 1
fi

# Make script executable
chmod +x deploy_templates.sh

echo "🚀 Starting template deployment..."
echo ""

# Run the deployment script
./deploy_templates.sh

echo ""
echo "✅ Template deployment completed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Verify templates in your R2 bucket"
echo "   2. Test code generation in your deployed application"
echo "   3. Create a new app and see if it works!"
