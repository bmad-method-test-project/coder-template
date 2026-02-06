data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU"
  description  = "The number of CPU cores"
  default      = "2"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "2 Cores"
    value = "2"
  }
  option {
    name  = "4 Cores"
    value = "4"
  }
  option {
    name  = "6 Cores"
    value = "6"
  }
  option {
    name  = "8 Cores"
    value = "8"
  }
}

data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory in GB"
  default      = "2"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "2 GB"
    value = "2"
  }
  option {
    name  = "4 GB"
    value = "4"
  }
  option {
    name  = "6 GB"
    value = "6"
  }
  option {
    name  = "8 GB"
    value = "8"
  }
}

data "coder_parameter" "home_disk_size" {
  name         = "home_disk_size"
  display_name = "Home disk size"
  description  = "The size of the home disk in GB"
  default      = "10"
  type         = "number"
  icon         = "/emojis/1f4be.png"
  mutable      = false
  option {
    name  = "Small (16GB)"
    value = "16"
  }
  option {
    name  = "Medium (32GB)"
    value = "32"
  }
  option {
    name  = "Large (64GB)"
    value = "64"
  }
}

data "coder_parameter" "bmad_version" {
  name         = "bmad_version"
  display_name = "BMAD Version"
  description  = "The BMAD version to use"
  default      = "6"
  type         = "number"
  icon         = "/emojis/1f4e6.png"
  mutable      = false
  option {
    name  = "v4"
    value = "4"
  }
  option {
    name  = "v6"
    value = "6"
  }
}

data "coder_parameter" "target_maturity_level" {
  name         = "target_maturity_level"
  display_name = "Target Maturity Level"
  description  = "What is the targeted maturity level for this workspace?"
  default      = "1"
  type         = "number"
  icon         = "/emojis/1f4c8.png"
  mutable      = true
  option {
    name  = "L1 | Concept Demo"
    value = "1"
  }
  option {
    name  = "L2 | Working Prototype"
    value = "2"
  }
  option {
    name  = "L3 | Releasable Solution"
    value = "3"
  }
  option {
    name  = "L4 | Enterprise-Ready"
    value = "4"
  }
}

data "coder_parameter" "user_technical_proficiency" {
  name         = "user_technical_proficiency"
  display_name = "User Technical Proficiency"
  description  = "The user's technical proficiency level"
  default      = "2"
  type         = "number"
  icon         = "/emojis/1f9e0.png"
  mutable      = true
  option {
    name  = "Beginner"
    value = "1"
  }
  option {
    name  = "Intermediate"
    value = "2"
  }
  option {
    name  = "Expert"
    value = "3"
  }
}

data "coder_parameter" "communication_language" {
  name         = "communication_language"
  display_name = "Communication Language"
  description  = "Language for AI agent communication"
  default      = "English"
  type         = "string"
  icon         = "/emojis/1f5e3.png"
  mutable      = true
  option {
    name  = "English"
    value = "English"
  }
  option {
    name  = "Deutsch"
    value = "Deutsch"
  }
}

data "coder_parameter" "document_output_language" {
  name         = "document_output_language"
  display_name = "Document Output Language"
  description  = "Language for generated documents"
  default      = "English"
  type         = "string"
  icon         = "/emojis/1f4dd.png"
  mutable      = true
  option {
    name  = "English"
    value = "English"
  }
  option {
    name  = "Deutsch"
    value = "Deutsch"
  }
}

data "coder_parameter" "project_name" {
  name         = "project_name"
  display_name = "Project Name"
  description  = "Display name for the project (leave empty to use workspace name)"
  default      = ""
  type         = "string"
  icon         = "/emojis/1f4c1.png"
  mutable      = true
}



data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}
data "coder_provisioner" "me" {}

locals {
  # Versioned defaults for new workspaces. These are applied on startup but do not
  # override user settings in settings.json.
  vscode_default_user_settings_json      = file("${path.module}/vscode/user-settings.json")
  vscode_default_workspace_settings_json = file("${path.module}/vscode/workspace-settings.json")
  vscode_default_locale_json             = file("${path.module}/vscode/locale.json")

  # Select Docker image based on BMAD version
  bmad_docker_image = data.coder_parameter.bmad_version.value == "4" ? "ghcr.io/bmad-method-test-project/bmad-coder-docker-v4:latest" : "ghcr.io/bmad-method-test-project/bmad-coder-docker-v6:latest"
}

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

resource "kubernetes_persistent_volume_claim_v1" "home" {
  metadata {
    name      = "coder-${data.coder_workspace.me.id}-home"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"     = "coder-pvc"
      "app.kubernetes.io/instance" = "coder-pvc-${data.coder_workspace.me.id}"
      "app.kubernetes.io/part-of"  = "coder"
      //Coder-specific labels.
      "com.coder.resource"       = "true"
      "com.coder.workspace.id"   = data.coder_workspace.me.id
      "com.coder.workspace.name" = data.coder_workspace.me.name
      "com.coder.user.id"        = data.coder_workspace_owner.me.id
      "com.coder.user.username"  = data.coder_workspace_owner.me.name
    }
    annotations = {
      "com.coder.user.email" = data.coder_workspace_owner.me.email
    }
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${data.coder_parameter.home_disk_size.value}Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "main" {
  count = data.coder_workspace.me.start_count
  depends_on = [
    kubernetes_persistent_volume_claim_v1.home
  ]
  wait_for_rollout = false
  metadata {
    name      = "coder-${data.coder_workspace.me.id}"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"     = "coder-workspace"
      "app.kubernetes.io/instance" = "coder-workspace-${data.coder_workspace.me.id}"
      "app.kubernetes.io/part-of"  = "coder"
      "com.coder.resource"         = "true"
      "com.coder.workspace.id"     = data.coder_workspace.me.id
      "com.coder.workspace.name"   = data.coder_workspace.me.name
      "com.coder.user.id"          = data.coder_workspace_owner.me.id
      "com.coder.user.username"    = data.coder_workspace_owner.me.name
    }
    annotations = {
      "com.coder.user.email" = data.coder_workspace_owner.me.email
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "coder-workspace"
        "app.kubernetes.io/instance" = "coder-workspace-${data.coder_workspace.me.id}"
        "app.kubernetes.io/part-of"  = "coder"
        "com.coder.resource"         = "true"
        "com.coder.workspace.id"     = data.coder_workspace.me.id
        "com.coder.workspace.name"   = data.coder_workspace.me.name
        "com.coder.user.id"          = data.coder_workspace_owner.me.id
        "com.coder.user.username"    = data.coder_workspace_owner.me.name
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"     = "coder-workspace"
          "app.kubernetes.io/instance" = "coder-workspace-${data.coder_workspace.me.id}"
          "app.kubernetes.io/part-of"  = "coder"
          "com.coder.resource"         = "true"
          "com.coder.workspace.id"     = data.coder_workspace.me.id
          "com.coder.workspace.name"   = data.coder_workspace.me.name
          "com.coder.user.id"          = data.coder_workspace_owner.me.id
          "com.coder.user.username"    = data.coder_workspace_owner.me.name
        }
      }
      spec {
        security_context {
          run_as_user     = 1001 # This is the UID of the 'coder' user in the coder workspace images
          fs_group        = 1001
          run_as_non_root = true
        }

        container {
          name              = "dev"
          image             = local.bmad_docker_image
          image_pull_policy = "Always"
          command           = ["sh", "-c", coder_agent.main.init_script]
          security_context {
            run_as_user = "1001" # This is the UID of the 'coder' user in the coder workspace images
          }
          env {
            name  = "CODER_AGENT_TOKEN"
            value = coder_agent.main.token
          }
          resources {
            requests = {
              "cpu"    = "250m"
              "memory" = "512Mi"
            }
            limits = {
              "cpu"    = "${data.coder_parameter.cpu.value}"
              "memory" = "${data.coder_parameter.memory.value}Gi"
            }
          }
          volume_mount {
            mount_path = "/home/coder"
            name       = "home"
            read_only  = false
          }
        }

        volume {
          name = "home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.home.metadata.0.name
            read_only  = false
          }
        }

        affinity {
          // This affinity attempts to spread out all workspace pods evenly across
          // nodes.
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["coder-workspace"]
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
