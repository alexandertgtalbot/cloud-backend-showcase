locals {
  # Get general variables.
  root_vars         = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  domain            = local.root_vars.locals.domain
  module_version    = local.root_vars.locals.module_version
  provider_version  = local.root_vars.locals.provider_version
  region            = local.root_vars.locals.default_region
  resource_prefix   = local.root_vars.locals.resource_prefix
  root_ou_id        = local.root_vars.locals.root_ou_id
  tags              = local.root_vars.locals.tags
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

remote_state {
  backend = "s3"
  config = {
    acl            = "private"
    bucket         = "${local.resource_prefix}-terraform-state"
    dynamodb_table = "${local.resource_prefix}-terraform-state-locks"
    encrypt        = true
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = local.module_version.account
}

inputs = {
  parent_id = dependency.parent_ou.outputs.id
}
