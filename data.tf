data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}
data "coder_provisioner" "me" {}

data "coder_parameter" "project_name" {
  name         = "project_name"
  display_name = "Project Name"
  description  = "Display name for the project (leave empty to use workspace name)"
  default      = ""
  type         = "string"
  icon         = "/emojis/1f4c1.png"
  mutable      = true
}

# Options for the number of CPU cores for the workspace. 
# This is used in the `kubernetes_deployment_v1` resource to set the appropriate 
# resource requests and limits for the workspace pod.
data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU"
  description  = "The number of CPU cores"
  type         = "number"
  form_type    = "radio"
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

# Amount of memory available to the workspace. 
# This is used in the `kubernetes_deployment_v1` resource to set the appropriate 
# resource requests and limits for the workspace pod.
data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory in GB"
  default      = "2"
  type         = "number"
  form_type    = "radio"
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

# Amount of storage available to the workspace. IMMUTABLE.
# This is used in the `kubernetes_persistent_volume_claim_v1` resource to set 
# the appropriate storage request for the PVC that is mounted as the user's home 
# directory in the workspace pod.
data "coder_parameter" "home_disk_size" {
  name         = "home_disk_size"
  display_name = "Home disk size"
  description  = "The size of the home disk in GB"
  default      = "16"
  type         = "number"
  form_type    = "dropdown"
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

# The version of BMAD that should be used in the workspace. 
# This is used in the `kubernetes_deployment_v1` resource to set the appropriate 
# image tag for the workspace pod.
data "coder_parameter" "bmad_version" {
  name         = "bmad_version"
  display_name = "BMAD Version"
  description  = "The BMAD version to use"
  default      = "6"
  type         = "number"
  icon         = "/emojis/1f4e6.png"
  form_type    = "radio"
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

# The maturity level of the project. 
# Used during startup to format the Agent instructions.
data "coder_parameter" "target_maturity_level" {
  name         = "target_maturity_level"
  display_name = "Target Maturity Level"
  description  = "What is the targeted maturity level for this workspace?"
  default      = "1"
  type         = "number"
  icon         = "/emojis/1f4c8.png"
  form_type    = "radio"
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

# The maturity level of the project. 
# Used during startup to format the Agent instructions.
data "coder_parameter" "user_technical_proficiency" {
  name         = "user_technical_proficiency"
  display_name = "User Technical Proficiency"
  description  = "The user's technical proficiency level"
  default      = "2"
  type         = "number"
  icon         = "/emojis/1f9e0.png"
  form_type    = "radio"
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

# The maturity level of the project. 
# Used during startup to format the Agent instructions.
data "coder_parameter" "communication_language" {
  name         = "communication_language"
  display_name = "Communication Language"
  description  = "Language for AI agent communication"
  default      = "English"
  type         = "string"
  icon         = "/emojis/1f5e3.png"
  form_type    = "radio"
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

# The maturity level of the project. 
# Used during startup to format the Agent instructions.
data "coder_parameter" "document_output_language" {
  name         = "document_output_language"
  display_name = "Document Output Language"
  description  = "Language for generated documents"
  default      = "English"
  type         = "string"
  icon         = "/emojis/1f4dd.png"
  form_type    = "radio"
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
