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

This template uses the `ghcr.io/prosellen/bmad-coder-docker:latest` Docker files to bootstrap the environment.

## Prerequisites

### Infrastructure

**Cluster**: This template requires an existing Kubernetes cluster

**Container Image**: This template uses the [codercom/enterprise-base:ubuntu image](https://github.com/coder/enterprise-images/tree/main/images/base) with some dev tools preinstalled. To add additional tools, extend this image or build it yourself.

### Authentication

This template authenticates using a `~/.kube/config`, if present on the server, or via built-in authentication if the Coder provisioner is running on Kubernetes with an authorized ServiceAccount. To use another [authentication method](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication), edit the template.

