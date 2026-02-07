# Data source to get the default organization
data "coderd_organization" "default" {
  is_default = true
}

# The Coder template resource
resource "coderd_template" "bmad_standard" {
  name         = var.template_name
  display_name = var.template_display_name
  description  = var.template_description
  icon         = var.template_icon

  # Use specified organization or default to the provider's default
  organization_id = var.organization_id != "" ? var.organization_id : data.coderd_organization.default.id

  # Template version configuration
  versions = [{
    # Path to the template directory (parent directory of this management folder)
    directory = "${path.module}/.."

    # Version identification
    name    = var.version_name
    message = var.version_message
    active  = var.version_is_active

    # Terraform variables passed to the workspace template
    tf_vars = [
      {
        name  = "namespace"
        value = var.namespace
      },
      {
        name  = "use_kubeconfig"
        value = tostring(var.use_kubeconfig)
      },
      {
        name  = "bmad_cli_version"
        value = var.bmad_cli_version
      }
    ]
  }]

  # Workspace behavior settings
  default_ttl_ms                     = var.default_ttl_ms
  activity_bump_ms                   = var.activity_bump_ms
  allow_user_cancel_workspace_jobs   = var.allow_user_cancel_workspace_jobs
  allow_user_auto_start              = var.allow_user_auto_start
  allow_user_auto_stop               = var.allow_user_auto_stop

  # ACL configuration
  # Note: ACL is an Enterprise feature. If you're using community edition,
  # this block can be removed or set to null
  acl = {
    # Grant 'use' permission to all organization members
    groups = [{
      id   = data.coderd_organization.default.id
      role = "use"
    }]
    users = []
  }

  lifecycle {
    # Prevent accidental deletion of the template
    prevent_destroy = false

    # Ignore changes to ACL if not using Enterprise features
    # Uncomment this if you're on Community Edition:
    # ignore_changes = [acl]
  }
}
