---
display_name: bmad-coder-template
description: Provision Kubernetes Deployments as Coder workspaces
maintainer_github: coder
verified: true
tags: [kubernetes, container]
---

# Remote Development on Kubernetes Pods

Create new [Coder workspaces](https://coder.com/docs/workspaces) with this template.

## Automated Deployment (GitHub Actions)

This repository includes an automated deployment workflow at `.github/workflows/deploy-template.yml`.

- Trigger: The deployment runs when a Git tag is created and pushed. Use GitHub Releases to publish a new version (recommended) — the release tag (for example `v0.1.0`) is used as the template `--name` and embedded in the push `--message`.
- Branch pushes: Merges to `main` run validation (init/fmt/validate) but do not publish a new template version unless a tag is present.
- Variables: The workflow reads GitHub environment/repository variables `CODER_URL`, `TEMPLATE_NAME`, `NAMESPACE`, `USE_KUBECONFIG`, `BMAD_CLI_VERSION`, and the secret `CODER_TOKEN` for authentication.

### PR title conventions (required)

Pull requests are required to use **Conventional Commits** style in the **PR title** (not necessarily in every individual commit).

Examples:
- `feat: ...` (minor)
- `fix: ...` (patch)
- `feat!: ...` or `refactor(scope)!: ...` (major)

See `.github/workflows/pr-title-conventional.yml` and `.github/pull_request_template.md`.

### Automated releases

Merges to `main` run `semantic-release`, which:
- Determines the next semantic version from merge commit messages (recommended: squash-merge using PR title)
- Updates `VERSION`
- Creates a Git tag like `vX.Y.Z` and a GitHub Release

The tag creation then triggers `.github/workflows/deploy-template.yml` to push the new version to Coder.

### Release Steps (recommended)
- Open a PR with a Conventional Commit style title (see the PR template).
- Merge the PR into `main`.
- The release workflow will create a GitHub Release + `vX.Y.Z` tag and update `VERSION`.
- The deploy workflow will run automatically on the new tag and push the version to Coder.

### Optional: Tag via CLI
If you prefer local tags instead of the Releases UI:

```
git tag v0.1.0
git push origin v0.1.0
```

This will trigger the same deployment logic using the tag name.

## Manually pushing

Alternatively, you can push the Template yourself

1. Download the Coder CLI from the official source: https://coder.com/docs/install/cli
2. Sign in using `coder login https://coder.example.com``
3. Use this command to push the changes from this repo to the Coder installation
    ```bash
    coder template push bmad-standard\
                --directory . \
                --name "< create a unique version name >" \
                --variable "use_kubeconfig=false" \
                --variable "namespace=coder" \
                --variable "bmad_cli_version=latest" \
                --message "< describe the updates made >" \
                --yes
    ```

## Details

This template uses the `ghcr.io/bmad-method-test-project/bmad-coder-docker:latest` Docker files to bootstrap the environment.

## Terraform / Terragrunt layout

Short description: this template is pure Terraform (no Terragrunt in this repo). The files are organized like this:

```
coder-template/
    main.tf                # entrypoint wiring data, locals, and resources
    variables.tf           # input variables for the template
    locals.tf              # derived values used across resources
    providers.tf           # Terraform and provider configuration
    data.tf                # Coder/Kubernetes data sources and parameters
    kubernetes.tf          # Kubernetes resources for the workspace
    vscode/                # VS Code defaults and locale
    .github/               # CI workflows and PR/release rules
    VERSION                # template version used by releases
    README.md              # usage and operational docs
```

### Security Configuration

The template runs workspaces with specific security settings:

**User ID: 1001**
- Pod security context: `run_as_user = 1001`, `fs_group = 1001`
- Container security context: `run_as_user = "1001"`
- Matches the `coder` user created in the Docker image (UID 1001, GID 1001)

**Why UID 1001?**
- The base Ubuntu image includes an `ubuntu` user at UID 1000
- Using UID 1001 avoids conflicts and ensures clean separation
- The Docker image explicitly creates the `coder` user with this UID

> **Important**: The UID/GID must match between the Dockerfile and this template's security context. If you change one, update the other.

## VS Code default settings

This template seeds VS Code settings for new workspaces from `vscode/default-settings.json` and the UI language from `vscode/locale.json`.

- The defaults are merged into the workspace user settings on startup.
- If a user later changes their own `settings.json`, their settings take precedence over the defaults.

## Prerequisites

### Infrastructure

**Cluster**: This template requires an existing Kubernetes cluster

**Container Image**: This template uses the [codercom/enterprise-base:ubuntu image](https://github.com/coder/enterprise-images/tree/main/images/base) with some dev tools preinstalled. To add additional tools, extend this image or build it yourself.

### Authentication

This template authenticates using a `~/.kube/config`, if present on the server, or via built-in authentication if the Coder provisioner is running on Kubernetes with an authorized ServiceAccount. To use another [authentication method](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication), edit the template.

