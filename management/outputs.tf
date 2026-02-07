output "template_id" {
  description = "The ID of the created template"
  value       = coderd_template.bmad_standard.id
}

output "template_name" {
  description = "The name of the template"
  value       = coderd_template.bmad_standard.name
}

output "template_url" {
  description = "URL to the template in the Coder UI"
  value       = "${trimprefix(data.coderd_organization.default.id, "/")}/${coderd_template.bmad_standard.name}"
}

output "active_version" {
  description = "Information about the active version"
  value = {
    name    = var.version_name
    message = var.version_message
  }
}

output "organization_id" {
  description = "The organization ID the template belongs to"
  value       = coderd_template.bmad_standard.organization_id
}
