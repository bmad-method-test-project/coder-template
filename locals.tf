locals {
  # Versioned defaults for new workspaces. These are applied on startup but do not
  # override user settings in settings.json.
  vscode_default_user_settings_json      = file("${path.module}/vscode/user-settings.json")
  vscode_default_workspace_settings_json = file("${path.module}/vscode/workspace-settings.json")
  vscode_default_locale_json             = file("${path.module}/vscode/locale.json")

  # Select Docker image based on BMAD version
  bmad_docker_image = data.coder_parameter.bmad_version.value == "4" ? "ghcr.io/bmad-method-test-project/bmad-coder-docker-v4:latest" : "ghcr.io/bmad-method-test-project/bmad-coder-docker-v6:latest"
}