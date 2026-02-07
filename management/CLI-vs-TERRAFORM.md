# Coderd Provider vs Coder CLI

Comparison of the two template deployment approaches.

## Overview

| Aspect | Coderd Provider (Terraform) | Coder CLI |
|--------|----------------------------|-----------|
| **Type** | Infrastructure as Code | Imperative commands |
| **State** | Tracked in Terraform state | No state tracking |
| **Configuration** | Declarative (HCL files) | Command-line flags |
| **Version Control** | Yes (terraform.tfvars) | Partial (scripts only) |
| **CI/CD** | Native Terraform workflow | Script-based |
| **Complexity** | Medium | Low |
| **Learning Curve** | Terraform knowledge required | CLI knowledge required |
| **Rollback** | Via state management | Manual re-push |
| **Multi-version** | Native support | Separate pushes |
| **Drift Detection** | Yes (terraform plan) | No |

## When to Use Coderd Provider

✅ **Use Terraform when**:

1. **You want infrastructure as code**
   - All configuration in version control
   - Changes tracked and auditable
   - Declarative resource management

2. **You have a team managing templates**
   - Multiple people need to deploy
   - Need to prevent configuration drift
   - Want to review changes before deployment

3. **You need advanced features**
   - Multiple active versions
   - Complex ACL configurations
   - Enterprise features (auto-start/stop policies)

4. **You use Terraform elsewhere**
   - Already familiar with Terraform
   - Can reuse existing CI/CD patterns
   - Consistent tooling across infrastructure

5. **You want automated testing**
   - `terraform plan` for dry-run validation
   - Easy to integrate with automated testing
   - Can use Terraform testing frameworks

## When to Use Coder CLI

✅ **Use CLI when**:

1. **Quick iterations during development**
   - Rapidly testing template changes
   - One-off deployments
   - Local development workflow

2. **Simple deployment needs**
   - Single person managing templates
   - No need for state tracking
   - Straightforward version management

3. **Minimal tooling**
   - Don't want to manage Terraform state
   - Prefer simple shell scripts
   - Less complex overall setup

4. **Legacy workflows**
   - Existing scripts already working
   - Team unfamiliar with Terraform
   - Migration effort not justified

## Feature Comparison

### Template Versioning

**Coderd Provider**:
```hcl
versions = [
  {
    name      = "v1.8.3"
    directory = "."
    active    = false
    message   = "Stable version"
  },
  {
    name      = "v1.8.4"
    directory = "."
    active    = true
    message   = "Latest features"
  }
]
```

**Coder CLI**:
```bash
# First version
coder template push bmad-standard --name v1.8.3

# Second version (overwrites if same template name)
coder template push bmad-standard --name v1.8.4
```

### Configuration Management

**Coderd Provider**:
```hcl
# terraform.tfvars (version controlled)
namespace        = "coder"
use_kubeconfig   = false
default_ttl_ms   = 0
```

**Coder CLI**:
```bash
# Command flags (in scripts)
coder template push \
  --variable "namespace=coder" \
  --variable "use_kubeconfig=false"
```

### Updates and Changes

**Coderd Provider**:
```bash
# See what will change
terraform plan

# Apply changes
terraform apply

# Rollback if needed
terraform state list
terraform apply -target=previous-version
```

**Coder CLI**:
```bash
# Push new version
coder template push bmad-standard --name v1.8.4

# Manual rollback
coder templates versions list bmad-standard
coder templates versions activate bmad-standard v1.8.3
```

### CI/CD Integration

**Coderd Provider**:
```yaml
- name: Deploy template
  env:
    CODER_SESSION_TOKEN: ${{ secrets.CODER_TOKEN }}
  run: |
    cd management
    terraform init
    terraform apply -auto-approve
```

**Coder CLI**:
```yaml
- name: Deploy template
  env:
    CODER_SESSION_TOKEN: ${{ secrets.CODER_TOKEN }}
  run: |
    coder template push bmad-standard \
      --directory . \
      --name "$VERSION" \
      --yes
```

## Migration Path

### From CLI to Terraform

1. **Import existing template**:
   ```bash
   cd management
   terraform init
   terraform import coderd_template.bmad_standard "coder/bmad-standard"
   ```

2. **Create matching configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit to match current template settings
   ```

3. **Verify no changes needed**:
   ```bash
   terraform plan  # Should show no changes
   ```

4. **Switch workflows**:
   - Enable Terraform workflow
   - Disable CLI workflow

### From Terraform to CLI

If you need to go back to CLI:

1. **Document current configuration**:
   ```bash
   terraform show
   ```

2. **Remove Terraform state**:
   ```bash
   terraform destroy  # Or just delete .terraform/
   ```

3. **Continue with CLI**:
   ```bash
   coder template push ...
   ```

## Compatibility

Both approaches:
- ✅ Work with regular Docker images
- ✅ Work with Dev Container/envbuilder templates
- ✅ Support template variables
- ✅ Support multiple versions
- ✅ Can be used in CI/CD

## Recommendation

**For this project specifically**:

Given that you:
- Have GitHub Actions CI/CD
- Want to test Dev Container integration
- Have multiple team members potentially deploying
- Need configuration in version control

**Recommendation**: **Use the Coderd Provider (Terraform)**

**Migration plan**:
1. ✅ Start with current CLI workflow (working)
2. ✅ Add Terraform configuration (done in this PR)
3. Test Terraform deployment in parallel
4. Once confident, switch CI/CD to Terraform
5. Keep CLI for local development/testing

## Hybrid Approach

You can use both:

- **Production**: Coderd Provider via GitHub Actions
- **Development**: CLI for quick iterations

This gives you:
- Production deployments tracked in Terraform
- Flexible local development workflow
- Best of both worlds

## Resources

- [Coderd Provider Docs](https://registry.terraform.io/providers/coder/coderd/latest/docs)
- [Coder CLI Reference](https://coder.com/docs/reference/cli)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/recommended-practices)
