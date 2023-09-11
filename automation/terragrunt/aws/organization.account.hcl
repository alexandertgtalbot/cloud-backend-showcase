locals {
  # Get general variables.
  root_vars         = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  domain            = local.root_vars.locals.domain
  region            = local.root_vars.locals.region
  root_ou_id        = local.root_vars.locals.root_ou_id
  tags              = local.root_vars.locals.tags
  module_version    = local.root_vars.locals.module_version
  provider_version  = local.root_vars.locals.provider_version
  terraform_version = local.root_vars.locals.terraform_version

  # Get environmental identifiers from parent directories.
  path        = reverse(split("/", get_terragrunt_dir()))
  environment = local.path[1]
  resident    = local.path[2]
  territory   = local.path[3]

  account_name = uuid()
}

dependency "parent_ou" {
  config_path  = "../"
  skip_outputs = false
}

generate "providers" {
  contents  = templatefile(find_in_parent_folders("providers.tftpl"), { args = local })
  path      = "providers.tf"
  if_exists = "overwrite"
}

terraform {
  source = local.module_version.account
}

inputs = {
  email     = "${local.account_name}@${local.domain}"
  name      = local.account_name
  parent_id = dependency.parent_ou.outputs.id
}
