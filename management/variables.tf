variable "template_name" {
  description = "The name of the Coder template"
  type        = string
  default     = "bmad-standard"
}

variable "template_display_name" {
  description = "Display name for the template in the Coder UI"
  type        = string
  default     = "BMAD Method Standard Template"
}

variable "template_description" {
  description = "Description of the template"
  type        = string
  default     = "Standard development environment for BMAD Method projects on Kubernetes"
}

variable "template_icon" {
  description = "Icon for the template (relative path or URL)"
  type        = string
  default     = "/icon/k8s.png"
}

variable "version_name" {
  description = "Name/tag for this template version (e.g., v1.8.3 or commit SHA)"
  type        = string
}

variable "version_message" {
  description = "Commit message or description for this version"
  type        = string
  default     = "Automated deployment via Terraform"
}

variable "version_is_active" {
  description = "Whether this version should be set as the active version"
  type        = bool
  default     = true
}

# Template variables passed to the workspace template
variable "namespace" {
  description = "Kubernetes namespace for workspaces"
  type        = string
  default     = "coder"
}

variable "use_kubeconfig" {
  description = "Whether to use kubeconfig for Kubernetes authentication"
  type        = bool
  default     = false
}

variable "bmad_cli_version" {
  description = "Version of BMAD CLI to use"
  type        = string
  default     = "latest"
}

# Optional: For explicit provider configuration
variable "coder_url" {
  description = "URL of the Coder deployment (defaults to CODER_URL env var)"
  type        = string
  default     = ""
  sensitive   = false
}

variable "coder_session_token" {
  description = "Session token for Coder API (defaults to CODER_SESSION_TOKEN env var)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "organization_id" {
  description = "Organization ID for the template (defaults to provider's default organization)"
  type        = string
  default     = ""
}

# Template workspace defaults
variable "default_ttl_ms" {
  description = "Default time-to-live for workspaces in milliseconds (0 = no auto-stop)"
  type        = number
  default     = 0 # No auto-stop by default
}

variable "activity_bump_ms" {
  description = "Activity bump duration in milliseconds (default: 1 hour)"
  type        = number
  default     = 3600000 # 1 hour
}

variable "allow_user_cancel_workspace_jobs" {
  description = "Whether users can cancel in-progress workspace jobs"
  type        = bool
  default     = true
}

variable "allow_user_auto_start" {
  description = "Whether users can auto-start workspaces (Enterprise feature)"
  type        = bool
  default     = true
}

variable "allow_user_auto_stop" {
  description = "Whether users can auto-stop workspaces (Enterprise feature)"
  type        = bool
  default     = true
}
