locals {
  # Get required variables from the root module.
  root_vars  = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  root_ou_id = local.root_vars.locals.root_ou_id
}

include "ou" {
  path = find_in_parent_folders("organization.ou.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  parent_id = local.root_ou_id
}
