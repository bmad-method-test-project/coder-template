---
display_name: bmad-coder-template
description: Provision Kubernetes Deployments as Coder workspaces
maintainer_github: coder
verified: true
tags: [kubernetes, container]
---

# Remote Development on Kubernetes Pods

Provision Kubernetes Pods as [Coder workspaces](https://coder.com/docs/workspaces) with this example template.

## Contributing

Currently, the GitHub Action to deploy the template to Coder does not work. Please update the template manually by pushing it to Coder.

1. Download the Coder CLI from the official source: https://coder.com/docs/install/cli
2. Sign in using `coder login https://coder.example.com``
3. Use `coder templates push` to push the changes from this repo to the Coder installation

## Details

This template uses the `ghcr.io/prosellen/bmad-coder-docker:latest` Docker files to bootstrap the environment.

## Prerequisites

### Infrastructure

**Cluster**: This template requires an existing Kubernetes cluster

**Container Image**: This template uses the [codercom/enterprise-base:ubuntu image](https://github.com/coder/enterprise-images/tree/main/images/base) with some dev tools preinstalled. To add additional tools, extend this image or build it yourself.

### Authentication

This template authenticates using a `~/.kube/config`, if present on the server, or via built-in authentication if the Coder provisioner is running on Kubernetes with an authorized ServiceAccount. To use another [authentication method](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#authentication), edit the template.

