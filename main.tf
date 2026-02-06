resource "coder_agent" "main" {
  # -- REQUIERED --
  os   = data.coder_provisioner.me.os
  arch = data.coder_provisioner.me.arch

  # --- OPTIONAL --
  # Initialization script that runs when the agent starts.
  startup_script = <<EOT
    set -euo pipefail

    # # Ensure mise activates in terminals
    # touch "$HOME/.bashrc" "$HOME/.bash_profile"

    # # Make sure mise is activated in bash shells - but should be inherited by the workspace.
    # grep -q 'mise activate bash' "$HOME/.bashrc" \
    #   || echo 'eval "$(mise activate bash)"' >> "$HOME/.bashrc"
    eval "$(mise activate bash)"

    # grep -q 'mise activate bash --shims' "$HOME/.bash_profile" \
    #   || echo 'eval "$(mise activate bash --shims)"' >> "$HOME/.bash_profile"
    eval "$(mise activate bash --shims)"

    # Create project directory and copy BMAD files from the Docker image to the user's project directory
    mkdir -p "$HOME/project/"
    rsync -a --ignore-existing "/usr/local/config/project/" "$HOME/project/"  

    # Install and activate Java, Node.js, and Python using mise
    mise trust --all
    mise use --global java
    mise use --global nodejs
    mise use --global python@3.13

    # Install jinja2 for configuration rendering
    mise exec -- pip3 install --break-system-packages jinja2

    # Render configuration files and AGENTS.md
    mise exec -- python3 /usr/local/config/scripts/render-config.py \
      --bmad-version "${data.coder_parameter.bmad_version.value}" \
      --project-root "$HOME/project" \
      --user-name "${data.coder_workspace_owner.me.name}" \
      --communication-language "${data.coder_parameter.communication_language.value}" \
      --document-output-language "${data.coder_parameter.document_output_language.value}" \
      --project-name "${data.coder_parameter.project_name.value != "" ? data.coder_parameter.project_name.value : data.coder_workspace.me.name}" \
      --user-technical-proficiency "${data.coder_parameter.user_technical_proficiency.value}" \
      --target-maturity-level "${data.coder_parameter.target_maturity_level.value}"

    # Seed VS Code default settings (versioned in the template)
    mkdir -p "$HOME/.vscode-server/data/Machine"
    cat <<'JSON' > "$HOME/.vscode-server/data/Machine/settings.json"
${local.vscode_default_workspace_settings_json}
JSON

    # Seed VS Code default User settings (versioned in the template)
    mkdir -p "$HOME/.vscode-server/data/User"
    cat <<'JSON' > "$HOME/.vscode-server/data/User/settings.json"
${local.vscode_default_user_settings_json}
JSON

    # Set VS Code display language to German (only if user hasn't set one).
    mkdir -p "$HOME/.vscode-server/data/User"
    if [ ! -f "$HOME/.vscode-server/data/User/locale.json" ]; then
      cat <<'JSON' > "$HOME/.vscode-server/data/User/locale.json"
${local.vscode_default_locale_json}
JSON
    fi

    # Install markdown-tree-parser globally
    # Since node/npm is not part of the bash profile at this time, it needs "mise exec" to run.
    mise exec -- npm install -g @kayvan/markdown-tree-parser
  EOT

  # Default is "non-blocking", although "blocking" is recommended.
  startup_script_behavior = "non-blocking"

  # TODO: add a link to Sharepoiint with internal documentation
  troubleshooting_url = "https://coder.com/docs/troubleshooting"

  # The starting directory when a user creates a shell session. Defaults to "$HOME".
  dir = "/home/coder/project"

  # A mapping of environment variables to set inside the workspace.
  # env = {
  #   "EXAMPLE_ENV_VAR" = "example_value"
  # }

  # The authentication type the agent will use. Must be one of: "token", "google-instance-identity", "aws-instance-identity", "azure-instance-identity".
  # auth = "token"

  # The list of built-in apps to display in the agent bar.
  display_apps {
    vscode                 = true
    vscode_insiders        = false
    web_terminal           = true
    ssh_helper             = false
    port_forwarding_helper = true
  }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }

  order = 1
}

# VS Code Web module
module "vscode-web" {
  count  = data.coder_workspace.me.start_count
  source = "registry.coder.com/coder/vscode-web/coder"

  # # By default, the version is "latest", but you can specify a version or range of versions if desired.
  # # See https://registry.coder.com/modules/coder/vscode-web#pin-a-specific-vs-code-web-version for details 
  # # on how to find and validate the latest version from the VS Code Repo
  # version = "1.4.3"

  agent_id                = coder_agent.main.id
  accept_license          = true
  auto_install_extensions = true

  # Open home by default (or point to a project folder you create)
  folder = "/home/coder/project"

  # The prefix to install vscode-web to.
  install_prefix = "/home/coder/.vscode-web"

  # Extensions to install automatically
  extensions = [
    "github.copilot",
    "github.copilot-chat",
    "MS-CEINTL.vscode-language-pack-de"
  ]

  # IMPORTANT: put extensions on the PVC so they persist
  extensions_dir = "/home/coder/.vscode-web/extensions"

  # Default Settings
  settings = {
    "telemetry.enableTelemetry"              = false
    "telemetry.enableCrashReporter"          = false
    "editor.fontSize"                        = 14
    "editor.tabSize"                         = 2
    "editor.formatOnSave"                    = true
    "files.autoSave"                         = "afterDelay"
    "files.autoSaveDelay"                    = 1000
    "extensions.autoUpdate"                  = true
    "extensions.autoCheckUpdates"            = true
    "security.workspace.trust.enabled"       = false
    "security.workspace.trust.startupPrompt" = "never"
    "coder.disableTelemetry"                 = true
  }

  # Who can access this workspace's VS Code Web instance - options are:
  # "public" (anyone with the link), "authenticated" (any logged-in user), or
  # "owner" (only the workspace owner).
  share = "authenticated"

  # Recommended if your admin has wildcard subdomains enabled
  subdomain = true
}
