# Template Management with Coderd Provider

This directory contains Terraform configuration for managing the BMAD Coder template using the `coderd` Terraform provider. This approach provides infrastructure-as-code management of template deployments, versioning, and configuration.

## Overview

The `coderd` provider allows you to manage Coder templates declaratively through Terraform, replacing manual CLI operations with version-controlled configuration.

### Benefits

- **Version control**: All template configuration in Git
- **Automation**: CI/CD-friendly deployment
- **Consistency**: Declarative configuration prevents drift
- **Auditing**: All changes tracked in Terraform state
- **Flexibility**: Works with any template type (regular Docker images or Dev Containers)

## Prerequisites

1. **Terraform** >= 1.2 installed
2. **Coder** instance >= 2.10.1
3. **Authentication**: Either:
   - Environment variables: `CODER_URL` and `CODER_SESSION_TOKEN`
   - Or explicit configuration in `terraform.tfvars`

## Quick Start

### 1. Create Configuration File

```bash
cd management
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
version_name    = "v1.8.3"
version_message = "Updated workspace configuration"
namespace       = "coder"
```

### 2. Set Authentication

Option A: Environment variables (recommended for CI/CD)
```bash
export CODER_URL="http://4.185.67.4"
export CODER_SESSION_TOKEN="your-session-token"
```

Option B: Configure in `terraform.tfvars`
```hcl
coder_url           = "http://4.185.67.4"
coder_session_token = "your-session-token"
```

### 3. Deploy Template

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

## Directory Structure

```
management/
├── main.tf                    # Template resource configuration
├── providers.tf               # Provider setup
├── variables.tf               # Input variables
├── outputs.tf                 # Outputs
├── terraform.tfvars.example   # Example configuration
└── README.md                  # This file
```

## Configuration Variables

### Template Identity

| Variable | Description | Default |
|----------|-------------|---------|
| `template_name` | Internal template name | `bmad-standard` |
| `template_display_name` | Display name in UI | `BMAD Method Standard Template` |
| `template_description` | Template description | - |
| `template_icon` | Icon path or URL | `/icon/k8s.png` |

### Version Information

| Variable | Description | Required |
|----------|-------------|----------|
| `version_name` | Version tag (e.g., `v1.8.3`) | Yes |
| `version_message` | Commit message | No |
| `version_is_active` | Set as active version | Yes (default: true) |

### Template Variables

These are passed to the workspace template (`../main.tf`):

| Variable | Description | Default |
|----------|-------------|---------|
| `namespace` | Kubernetes namespace | `coder` |
| `use_kubeconfig` | Use kubeconfig auth | `false` |
| `bmad_cli_version` | BMAD CLI version | `latest` |

### Workspace Behavior

| Variable | Description | Default |
|----------|-------------|---------|
| `default_ttl_ms` | Auto-stop timeout (ms) | `0` (disabled) |
| `activity_bump_ms` | Activity bump duration | `3600000` (1h) |
| `allow_user_cancel_workspace_jobs` | Users can cancel jobs | `true` |
| `allow_user_auto_start` | Users can auto-start (Enterprise) | `true` |
| `allow_user_auto_stop` | Users can auto-stop (Enterprise) | `true` |

## Version Management

### Creating a New Version

Each time you make changes to the template or want to deploy a new version:

1. Update `version_name` in `terraform.tfvars`:
   ```hcl
   version_name = "v1.8.4"
   version_message = "feat: Added new workspace configuration"
   ```

2. Apply changes:
   ```bash
   terraform apply
   ```

### Multiple Versions

To maintain multiple versions simultaneously, modify the `versions` list in `main.tf`:

```hcl
versions = [
  {
    directory = "${path.module}/.."
    name      = "v1.8.3"
    message   = "Stable version"
    active    = false
  },
  {
    directory = "${path.module}/.."
    name      = "v1.8.4"
    message   = "Latest version"
    active    = true
  }
]
```

**Note**: The `directory` hash determines when a new version is created. Changing template files will automatically trigger a new version.

## CI/CD Integration

### GitHub Actions Example

The workflow in `.github/workflows/deploy-template.yml` can be updated to use Terraform:

```yaml
- name: Deploy template with Terraform
  env:
    CODER_URL: ${{ vars.CODER_URL }}
    CODER_SESSION_TOKEN: ${{ secrets.CODER_TOKEN }}
  run: |
    cd management
    
    # Create terraform.tfvars from environment
    cat > terraform.tfvars <<EOF
    version_name    = "${{ steps.version.outputs.VERSION }}"
    version_message = "${{ steps.pr_info.outputs.pr_title }}"
    namespace       = "${{ vars.CODER_NAMESPACE }}"
    use_kubeconfig  = ${{ vars.USE_KUBECONFIG }}
    EOF
    
    # Deploy
    terraform init
    terraform apply -auto-approve
```

## Outputs

After applying, Terraform provides useful outputs:

```bash
terraform output template_id        # UUID of the template
terraform output template_name      # Template name
terraform output template_url       # URL path to template
terraform output active_version     # Active version info
```

## Enterprise Features

If you're using Coder Enterprise, you can configure:

- **ACL**: Access control lists for users and groups
- **Auto-start/stop policies**: Days of week, quiet hours
- **Dormancy settings**: Auto-delete inactive workspaces
- **Failure TTL**: Auto-cleanup for failed workspaces

Modify the `acl` block in `main.tf` and add additional Enterprise-specific variables.

## Troubleshooting

### Authentication Issues

```bash
# Verify connection
export CODER_URL="http://4.185.67.4"
export CODER_SESSION_TOKEN="your-token"
coder login --token "${CODER_SESSION_TOKEN}" "${CODER_URL}"
```

### Template Logs

To see build logs during template version creation:

```bash
export TF_LOG=INFO
terraform apply
```

### State Management

Terraform state tracks the template. If the state is lost:

```bash
# Import existing template
terraform import coderd_template.bmad_standard "coder/bmad-standard"
```

## Migration from CLI

If you're currently using `coder template push`:

1. **One-time import**:
   ```bash
   cd management
   terraform init
   terraform import coderd_template.bmad_standard "your-org/bmad-standard"
   ```

2. **Create initial tfvars** based on your current template

3. **Apply** to align state:
   ```bash
   terraform apply
   ```

4. **Update CI/CD** to use Terraform instead of CLI

## Best Practices

1. **Version naming**: Use semantic versioning (v1.2.3) or Git tags
2. **Messages**: Write descriptive commit messages for versions
3. **State backend**: Use remote state for team collaboration
4. **Secrets**: Never commit `terraform.tfvars` with tokens
5. **Testing**: Test template changes in a staging environment first

## Resources

- [Coderd Provider Documentation](https://registry.terraform.io/providers/coder/coderd/latest/docs)
- [coderd_template Resource](https://registry.terraform.io/providers/coder/coderd/latest/docs/resources/template)
- [Coder Templates Guide](https://coder.com/docs/admin/templates)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
