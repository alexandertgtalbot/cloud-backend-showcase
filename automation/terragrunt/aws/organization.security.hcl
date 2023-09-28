locals {
  # Get general variables.
  root_vars             = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  region                = local.root_vars.locals.region
  tags                  = local.root_vars.locals.tags
  management_account_id = local.root_vars.locals.management_account_id
  module_version        = local.root_vars.locals.module_version
  provider_version      = local.root_vars.locals.provider_version
  terraform_version     = local.root_vars.locals.terraform_version

  governance_roles_vars  = read_terragrunt_config(find_in_parent_folders("governance.roles.hcl"))
  resident_policies_path = local.governance_roles_vars.locals.policies.resident
}

generate "providers" {
  contents  = templatefile(find_in_parent_folders("providers.tftpl"), { args = merge(local, { iam_role = "arn:aws:iam::${dependency.parent.outputs.id}:role/${dependency.parent.outputs.role_name}" }) })
  path      = "providers.tf"
  if_exists = "overwrite"
}

dependency "parent" {
  config_path                             = "../"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  skip_outputs                            = false

  mock_outputs = {
    id        = "123456789012"
    role_name = "mock-role"
  }
}

terraform {
  source = local.module_version.security
}

inputs = {
  inline_policy_path    = local.resident_policies_path
  management_account_id = local.management_account_id
}
