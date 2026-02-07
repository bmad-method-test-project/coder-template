# GitHub Copilot Instructions for Coder Template Repository

## Repository Purpose

This repository contains Terraform-based templates for **Coder Community Edition** that are automatically deployed via GitHub Actions. These templates provision development workspaces on Kubernetes clusters.

## Key Technologies

### Coder.com Templates
- **Documentation**: https://coder.com/docs/admin/templates
- **Template Development**: https://coder.com/docs/admin/templates/dev-templates
- **Template Examples**: https://github.com/coder/coder/tree/main/examples/templates
- Templates define the infrastructure for developer workspaces
- Written in Terraform with Coder-specific providers and resources
- Support parameters for customization (instance size, disk size, etc.)

### Terraform
- **Coder Terraform Provider**: https://registry.terraform.io/providers/coder/coder/latest/docs
- **Kubernetes Provider**: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
- **Version**: Use Terraform 1.x or later
- All templates must use HCL syntax
- Required providers: `coder/coder` and `hashicorp/kubernetes`

### Kubernetes
- **Kubernetes Provider Docs**: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
- Templates provision workspaces as Kubernetes Pods or Deployments
- Common resources: `kubernetes_pod`, `kubernetes_persistent_volume_claim`, `kubernetes_service`
- Use namespaces for workspace isolation
- Configure resource limits (CPU, memory) appropriately

### GitHub Actions & Template Deployment
- **Two Deployment Approaches**:
  1. **Coderd Provider (Recommended)**: Infrastructure as Code via Terraform
     - Workflow: `.github/workflows/deploy-template-terraform.yml`
     - Configuration: `management/` directory
     - Provider: https://registry.terraform.io/providers/coder/coderd/latest/docs
     - Declarative, state-managed, version-controlled
  2. **Coder CLI (Legacy)**: Imperative deployment via CLI commands
     - Workflow: `.github/workflows/deploy-template.yml`
     - CLI Reference: https://coder.com/docs/reference/cli
     - Coder Setup Action: https://github.com/coder/setup-action
- **Coderd Provider Management**: 
  - Template deployment: https://coder.com/docs/admin/templates/managing-templates/change-management
  - Resource documentation: https://registry.terraform.io/providers/coder/coderd/latest/docs/resources/template
  - See `management/README.md` for detailed setup
- Authentication via `CODER_URL` and `CODER_SESSION_TOKEN` environment variables/secrets

## Template Structure Guidelines

### Required Resources

Every Coder template should include:

1. **coder_agent** - Runs inside the workspace for CLI/IDE connectivity
   ```hcl
   resource "coder_agent" "main" {
     arch = data.coder_provisioner.main.arch
     os   = data.coder_provisioner.main.os
   }
   ```

2. **coder_workspace** data source - Access workspace metadata
   ```hcl
   data "coder_workspace" "me" {}
   ```

3. **Kubernetes Pod/Deployment** - The actual workspace container
   - Must include the coder agent init script
   - Should use persistent volumes for data persistence
   - Configure appropriate resource requests/limits

### Template Parameters

Use `coder_parameter` for user customization:
```hcl
data "coder_parameter" "instance_type" {
  name         = "instance_type"
  display_name = "Instance Type"
  description  = "Select the workspace instance type"
  type         = "string"
  default      = "small"
  mutable      = false
  
  option {
    name  = "Small"
    value = "small"
  }
  option {
    name  = "Medium"
    value = "medium"
  }
}
```

### Metadata and Apps

1. **coder_metadata** - Display workspace information in Coder UI
2. **coder_app** - Expose applications (web services, ports) from workspace

## Best Practices

### Template Development
- Keep templates modular and reusable
- Use meaningful variable names and descriptions
- Include comprehensive README.md for each template
- Test templates locally before committing: `coder template create --test`
- Use `startup_script` in coder_agent for initialization tasks

### Kubernetes Configuration
- Always set resource requests and limits
- Use persistent volumes for workspace data
- Implement proper RBAC if needed
- Use appropriate image pull policies
- Consider using init containers for setup tasks

### Security
- Never hardcode secrets in templates
- Use Kubernetes secrets for sensitive data
- Implement network policies if required
- Follow principle of least privilege for service accounts

### Performance
- Optimize container images (use slim/alpine variants when possible)
- Pre-pull frequently used images to nodes
- Set appropriate startup probe timeouts
- Consider node affinity for workspace placement

## Common Template Patterns

### Persistent Home Directory
```hcl
resource "kubernetes_persistent_volume_claim" "home" {
  metadata {
    name      = "coder-${data.coder_workspace.me.id}-home"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${data.coder_parameter.disk_size.value}Gi"
      }
    }
  }
}
```

### Init Script in Agent
```hcl
resource "coder_agent" "main" {
  # ... other configuration
  
  startup_script = <<-EOT
    #!/bin/bash
    set -e
    
    # Install tools
    sudo apt-get update
    sudo apt-get install -y git curl
    
    # Clone repositories
    if [ ! -d ~/project ]; then
      git clone https://github.com/org/repo ~/project
    fi
  EOT
}
```

### Exposing Web Applications
```hcl
resource "coder_app" "code_server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:8080"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"
}
```

## CI/CD with GitHub Actions

### Expected Workflow
- Templates pushed to `main` branch trigger deployment
- Workflow authenticates with Coder server
- Templates are validated and pushed using Coder CLI
- Consider using template versioning for rollback capability

### Environment Variables/Secrets
- `CODER_URL`: URL of your Coder deployment
- `CODER_SESSION_TOKEN`: Authentication token for CLI
- Additional secrets as needed for your infrastructure

## References and Resources

- **Coder Docs**: https://coder.com/docs
- **Coder GitHub**: https://github.com/coder/coder
- **Community Templates**: https://github.com/coder/coder/tree/main/examples/templates
- **Terraform Registry**: https://registry.terraform.io/
- **Kubernetes Docs**: https://kubernetes.io/docs/

## Git Commit Guidelines
- Use conventional commit messages (e.g., feat:, fix:, docs:, style:, refactor:, test:, chore:). (https://www.conventionalcommits.org/en/v1.0.0/)
- First line is 50 characters or less.
  - Separate subject from body with a blank line.
  - Use the body to explain what and why vs. how.
- Include issue references in commit messages when applicable.

## Repository Structure

This repository is organized into two main parts:

1. **Workspace Template** (`/` root) - Defines what runs inside workspaces
2. **Template Management** (`/management/`) - Defines how the template is deployed

```
coder-template/
  # Workspace Template (what runs inside workspaces)
  main.tf                # entrypoint wiring data, locals, and resources
  variables.tf           # input variables for the workspace 
  locals.tf              # derived values used across resources
  providers.tf           # Terraform providers (coder, kubernetes)
  data.tf                # Coder/Kubernetes data sources and parameters
  kubernetes.tf          # Kubernetes resources for the workspace
  vscode/                # VS Code defaults and locale
    
  # Template Management (how the template is deployed to Coder)
  management/            # Coderd provider for template deployment
    main.tf            # coderd_template resource
    providers.tf       # coderd provider configuration
    variables.tf       # deployment variables
    outputs.tf         # deployment outputs
    README.md          # deployment documentation
    QUICKSTART.md      # getting started guide
    CLI-vs-TERRAFORM.md # comparison of approaches
    
  # CI/CD and Documentation
  .github/
    workflows/
      deploy-template-terraform.yml  # Terraform deployment (recommended)
      deploy-template.yml            # CLI deployment (legacy)
  VERSION                # template version for releases
  README.md              # main documentation
```

**Important**: The `management/` directory uses the `coderd` provider to deploy and manage the template itself, while the root directory files define the workspace infrastructure that users will provision.

## Documentation Guidelines
- Keep README.md up to date with major changes.
- Write brief, clear descriptions for developers and architects with limited Terraform/Terragrunt knowledge.
- Maintain a dependency/tooling list near the top of README.md, including links to official docs and installation guides.

## Code Style

- Use 2 spaces for indentation in HCL files
- Follow Terraform naming conventions (snake_case)
- Group related resources together
- Comment complex logic or non-obvious configurations
- Use `terraform fmt` to format all `.tf` files

## Testing

Before committing templates:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Test template creation: `coder template create <name> --directory .`
4. Verify workspace creation from the template
5. Check agent connectivity and apps functionality
