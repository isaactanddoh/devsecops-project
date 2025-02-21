locals {
  # Workspace validations
  validations = {
    prod = {
      cidr_blocks = (
        terraform.workspace == "prod" &&
        contains(var.allowed_cidr_blocks, "0.0.0.0/0")
        ? file("ERROR: Production environment cannot allow unrestricted access (0.0.0.0/0)")
        : null
      )

      backup_retention = (
        terraform.workspace == "prod" &&
        local.workspace_config[terraform.workspace].backup_retention_days < 30
        ? file("ERROR: Production backup retention must be at least 30 days")
        : null
      )

      log_retention = (
        terraform.workspace == "prod" &&
        local.workspace_config[terraform.workspace].log_retention_days < 30
        ? file("ERROR: Production log retention must be at least 30 days")
        : null
      )
    }
  }
} 