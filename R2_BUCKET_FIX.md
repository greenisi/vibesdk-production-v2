# R2 Bucket Templates Fix

## Problem Identified

The code generation feature was failing with "Failed to start code generation" error because the R2 bucket `vibesdk-templates` is empty. The application requires templates to be present in the R2 bucket to initialize code generation.

### Root Cause

When users try to create a new app, the code calls `SandboxSdkClient.listTemplates()` which attempts to fetch `template_catalog.json` from the R2 bucket. If this file doesn't exist, the entire code generation process fails at the initialization stage.

**Error flow:**
1. User submits "Hey" or "Website" request
2. Backend calls `getTemplateForQuery()` 
3. This calls `SandboxSdkClient.listTemplates(env)`
4. R2 bucket is queried for `template_catalog.json`
5. File not found → Error thrown
6. Code generation fails with "Failed to start code generation"

## Solution

The R2 bucket needs to be populated with:
1. `template_catalog.json` - Master list of all available templates
2. Template zip files (e.g., `react-vite-ts.zip`, `vanilla-vite-ts.zip`, etc.)

### Automated Fix (Recommended)

I've created a GitHub Action workflow that will automatically deploy templates to your R2 bucket.

**Steps to use:**

1. **Add Cloudflare Secrets to GitHub Repository**
   
   Go to your repository settings → Secrets and variables → Actions → New repository secret
   
   Add these two secrets:
   - `CLOUDFLARE_API_TOKEN` - Your Cloudflare API token with R2 write permissions
   - `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID

2. **Trigger the Workflow**
   
   - Go to Actions tab in your GitHub repository
   - Click on "Deploy Templates to R2" workflow
   - Click "Run workflow" button
   - Select `main` branch and click "Run workflow"

   The workflow will:
   - Generate all templates from the templates repository
   - Create optimized zip files for each template
   - Upload `template_catalog.json` to R2
   - Upload all template zip files to R2

3. **Verify Deployment**
   
   The workflow will show a summary of uploaded files. You can also verify by checking your R2 bucket in the Cloudflare dashboard.

### Quick Fix Script (Alternative)

If you prefer to deploy templates manually, use the provided deployment script:

```bash
# 1. Set your Cloudflare credentials
export CLOUDFLARE_API_TOKEN="your_api_token_here"
export CLOUDFLARE_ACCOUNT_ID="your_account_id_here"

# 2. Run the deployment script
./deploy-templates-to-r2.sh
```

The script will:
- Validate your credentials
- Check for required dependencies
- Deploy all templates to your R2 bucket
- Provide a summary of uploaded files

### Manual Fix (Advanced)

For more control over the deployment process:

```bash
# 1. Navigate to your project directory
cd /path/to/vibesdk-production-v2

# 2. Set environment variables
export CLOUDFLARE_API_TOKEN="your_api_token_here"
export CLOUDFLARE_ACCOUNT_ID="your_account_id_here"
export R2_BUCKET_NAME="vibesdk-templates"
export LOCAL_R2="false"  # Use "true" for local development

# 3. Run the deployment script directly
cd templates
chmod +x deploy_templates.sh
./deploy_templates.sh
```

### Getting Your Cloudflare Credentials

**API Token:**
1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Use "Edit Cloudflare Workers" template or create a custom token
4. Ensure it has these permissions:
   - Account → Workers R2 Storage → Edit
   - Account → Account Settings → Read

**Account ID:**
1. Go to https://dash.cloudflare.com/
2. Select your account
3. The Account ID is visible in the right sidebar

## Verification

After deploying templates, test code generation:

1. Go to your deployed application: `https://vibesdk-production-v2.zae003.workers.dev`
2. Create a new account or sign in
3. Try creating a new app with a simple prompt like "Create a counter app"
4. Code generation should now work successfully

## Expected Behavior

Once templates are deployed:
- ✅ Code generation will start immediately
- ✅ Users will see "Generating Blueprint" → "Generating code" → Success
- ✅ Template selection will work based on user prompts
- ✅ Preview URLs will be generated successfully

## Troubleshooting

### Issue: Workflow fails with authentication error
**Solution:** Double-check that CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID secrets are correctly set in GitHub repository settings.

### Issue: Upload fails for specific files
**Solution:** Ensure your Cloudflare API token has R2 write permissions. You may need to recreate the token with correct permissions.

### Issue: Code generation still fails after deployment
**Solution:** 
1. Verify that `template_catalog.json` exists in R2 bucket
2. Check Cloudflare Workers logs for specific error messages
3. Ensure R2 bucket name in `wrangler.jsonc` matches the deployed bucket name

## Additional Notes

- The templates repository (`https://github.com/cloudflare/vibesdk-templates`) is already cloned in the `templates/` directory
- Templates are generated on-the-fly by the deployment script from the definitions
- The deployment script creates optimized zip files for fast extraction in Workers
- Both local and remote R2 deployments are supported (controlled by `LOCAL_R2` env var)

## Next Steps

After fixing the R2 bucket:
1. ✅ Code generation will work
2. Consider setting up automatic template deployment on template changes
3. Monitor R2 bucket usage and costs
4. Keep templates repository updated by periodically pulling latest changes

---

**Created:** $(date)
**Issue:** Code generation failing due to empty R2 bucket
**Status:** Fix implemented and ready to deploy
