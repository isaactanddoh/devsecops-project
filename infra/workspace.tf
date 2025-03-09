# Create and configure workspaces
resource "null_resource" "workspace_setup" {
  provisioner "local-exec" {
    command = <<-EOT
      terraform workspace select -or-create dev 2>nul || exit 0
      terraform workspace select -or-create staging 2>nul || exit 0
      terraform workspace select -or-create prod 2>nul || exit 0
    EOT
  }
}

# Validate workspace
locals {
  allowed_workspaces = ["dev", "staging", "prod"]

  validate_workspace = (
    contains(local.allowed_workspaces, terraform.workspace)
    ? null
    : file("ERROR: Invalid workspace. Must be one of: ${join(", ", local.allowed_workspaces)}")
  )
}