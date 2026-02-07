terraform {
  required_version = ">= 1.2"

  required_providers {
    coderd = {
      source  = "coder/coderd"
      version = "~> 0.0.12"
    }
  }
}

provider "coderd" {
  # URL and token are read from environment variables:
  # - CODER_URL
  # - CODER_SESSION_TOKEN
  # Or can be set explicitly:
  # url   = var.coder_url
  # token = var.coder_session_token
}
