# Quick Start: Deploy with Coderd Provider

This guide walks you through deploying your first template version using the `coderd` Terraform provider.

## Prerequisites

- Terraform >= 1.2 installed
- Access to your Coder instance (http://4.185.67.4)
- Coder session token (API token)

## Step 1: Get Your Session Token

```bash
# Option 1: Generate via CLI
coder login http://4.185.67.4
coder tokens create --lifetime 720h  # 30 days

# Option 2: Generate via UI
# Navigate to http://4.185.67.4/cli-auth
# Copy the token displayed
```

## Step 2: Set Environment Variables

```bash
export CODER_URL="http://4.185.67.4"
export CODER_SESSION_TOKEN="your-token-here"
```

## Step 3: Create Your Configuration

```bash
cd management
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Minimal required configuration
version_name    = "v1.8.3"
version_message = "Initial deployment with coderd provider"

# Template deployment settings
namespace        = "coder"
use_kubeconfig   = false
bmad_cli_version = "latest"
```

## Step 4: Initialize and Deploy

```bash
# Initialize Terraform (downloads providers)
terraform init

# Preview what will be created
terraform plan

# Deploy the template
terraform apply
```

You'll see output like:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

template_id = "123e4567-e89b-12d3-a456-426614174000"
template_name = "bmad-standard"
template_url = "coder/bmad-standard"
active_version = {
  "message" = "Initial deployment with coderd provider"
  "name" = "v1.8.3"
}
```

## Step 5: Verify in Coder UI

Navigate to: `http://4.185.67.4/templates/bmad-standard`

You should see your template with version `v1.8.3` marked as active.

## Next Steps

### Deploy a New Version

1. Make changes to your template files (e.g., `main.tf`, `kubernetes.tf`)
2. Update `version_name` in `terraform.tfvars`:
   ```hcl
   version_name = "v1.8.4"
   version_message = "feat: Updated workspace configuration"
   ```
3. Apply changes:
   ```bash
   terraform apply
   ```

### Manage Multiple Versions

Edit `main.tf` to add multiple versions:

```hcl
versions = [
  {
    directory = "${path.module}/.."
    name      = "v1.8.3"
    message   = "Stable version"
    active    = false
    tf_vars = [
      # ... same tf_vars
    ]
  },
  {
    directory = "${path.module}/.."
    name      = "v1.8.4"
    message   = "Latest version"
    active    = true
    tf_vars = [
      # ... same tf_vars
    ]
  }
]
```

### View Terraform State

```bash
# List managed resources
terraform state list

# Show template details
terraform state show coderd_template.bmad_standard

# Get outputs
terraform output
```

## Troubleshooting

### "Error: Invalid authentication"

1. Verify your token is still valid:
   ```bash
   coder login --token "$CODER_SESSION_TOKEN" "$CODER_URL"
   ```

2. Generate a new token if expired:
   ```bash
   coder tokens create --lifetime 720h
   ```

### "Error: Organization not found"

The provider tries to use the default organization. To specify explicitly:

```hcl
# In terraform.tfvars
organization_id = "your-org-uuid"
```

### See Build Logs

```bash
export TF_LOG=INFO
terraform apply
```

### Template Won't Update

If the template directory hasn't changed, Terraform won't create a new version. Force recreation:

```bash
# Taint the resource
terraform taint coderd_template.bmad_standard

# Or change version_name in terraform.tfvars
version_name = "v1.8.4"  # Was v1.8.3
```

## CI/CD Integration

To use in GitHub Actions, switch to the new workflow:

```bash
# Rename or disable the old workflow
mv .github/workflows/deploy-template.yml .github/workflows/deploy-template.yml.disabled

# Enable the new Terraform workflow
mv .github/workflows/deploy-template-terraform.yml .github/workflows/deploy-template.yml
```

The workflow will automatically:
- Read VERSION file
- Extract PR title for version message
- Create terraform.tfvars
- Deploy the template

## Migration from CLI to Terraform

If you already have a template deployed via CLI:

```bash
cd management

# Import existing template
terraform init
terraform import coderd_template.bmad_standard "coder/bmad-standard"

# Create tfvars matching current configuration
cp terraform.tfvars.example terraform.tfvars
# Edit to match your current settings

# Apply to sync state
terraform plan  # Should show no changes
terraform apply
```

## Best Practices

1. **Version Naming**: Use semantic versioning (v1.2.3) or Git commit SHAs
2. **State Management**: Consider using a remote backend for team collaboration:
   ```hcl
   # In providers.tf
   terraform {
     backend "s3" {
       # or "azurerm", "gcs", etc.
     }
   }
   ```
3. **Secrets**: Never commit `terraform.tfvars` with tokens
4. **Testing**: Test in a dev environment first
5. **Rollback**: Keep previous versions available with `active = false`

## Resources

- [Full Documentation](./README.md)
- [Coderd Provider Docs](https://registry.terraform.io/providers/coder/coderd/latest/docs)
- [Terraform Basics](https://learn.hashicorp.com/terraform)
