# Templates Deployment Fix

## Issue
The Vibe platform is failing at the "Generating Blueprint" stage with a 500 error. The root cause is that the R2 bucket `vibesdk-templates` is empty - templates have not been deployed to it.

## Root Cause Analysis
1. The code expects templates to be stored in the R2 bucket `TEMPLATES_BUCKET` (bound to `vibesdk-templates`)
2. The templates are defined in the GitHub repository: https://github.com/cloudflare/vibesdk-templates
3. The setup process (scripts/setup.ts) is supposed to clone this repository and run `deploy_templates.sh` to upload templates to R2
4. This deployment step was never executed, leaving the R2 bucket empty
5. When users try to generate code, the system fails when trying to fetch template files from the empty R2 bucket

## Solution
Deploy the templates to the R2 bucket by running the deployment script.

### Steps to Fix

1. **Clone the templates repository** (if not already done):
   ```bash
   cd /path/to/vibesdk-production-v2
   git clone https://github.com/cloudflare/vibesdk-templates templates
   ```

2. **Set up environment variables**:
   ```bash
   export R2_BUCKET_NAME="vibesdk-templates"
   export LOCAL_R2="false"  # Use "true" for local development, "false" for production
   ```

3. **Ensure you're authenticated with Cloudflare**:
   ```bash
   npx wrangler login
   # Or set CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID environment variables
   ```

4. **Run the deployment script**:
   ```bash
   cd templates
   ./deploy_templates.sh
   ```

   This script will:
   - Generate template files from definitions
   - Create optimized zip files for each template
   - Generate a template catalog JSON
   - Upload all files to the R2 bucket

5. **Verify deployment**:
   After deployment, the R2 bucket should contain:
   - `template_catalog.json` - Catalog of all available templates
   - `c-code-next-runner.zip` - Next.js template
   - `c-code-react-runner.zip` - React template
   - `vite-cf-DO-KV-runner.zip` - Vite + Durable Objects + KV template
   - `vite-cf-DO-runner.zip` - Vite + Durable Objects template
   - `vite-cf-DO-v2-runner.zip` - Vite + Durable Objects v2 template
   - `vite-cfagents-runner.zip` - Vite + CF Agents template

### Alternative: Use the Setup Script
The project includes a comprehensive setup script that handles template deployment:

```bash
cd /path/to/vibesdk-production-v2
npm install  # or bun install
npx tsx scripts/setup.ts
```

This will guide you through the complete setup process including template deployment.

## Expected Outcome
After deploying templates:
1. Users can successfully create apps through the Vibe platform
2. The "Generating Blueprint" step will complete successfully
3. Code generation will proceed through all stages
4. Users will be able to deploy and preview their generated applications

## Technical Details
- **R2 Bucket**: `vibesdk-templates`
- **Binding Name**: `TEMPLATES_BUCKET`
- **Templates Repository**: https://github.com/cloudflare/vibesdk-templates
- **Deployment Script**: `templates/deploy_templates.sh`
- **Template Catalog**: `template_catalog.json` (uploaded to R2 root)
- **Template Archives**: `[template-name].zip` (uploaded to R2 root)

## Logs Evidence
From Cloudflare Worker logs, the error sequence was:
1. "Starting code generation process" ✓
2. "Asking AI to select a template" ✓
3. "AI template selection result: c-code-react-runner" ✓
4. "Retrieving template details" ✓
5. **"Failed to fetch files"** ❌ - This is where it fails because R2 bucket is empty

The error occurs in `sandboxSdkClient.ts` -> `getTemplateDetails()` -> `getFiles()` when trying to read template files from the R2 bucket.
