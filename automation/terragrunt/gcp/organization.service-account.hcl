locals {
  # Get required variables from the root module.
  root_vars            = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  billing_account      = local.root_vars.locals.billing_account
  default_region       = local.root_vars.locals.default_region
  group_billing_admins = local.root_vars.locals.group_billing_admins
  group_org_admins     = local.root_vars.locals.group_org_admins
  labels               = local.root_vars.locals.labels
  module_version       = local.root_vars.locals.module_version
  org_id               = local.root_vars.locals.org_id
  provider_version     = local.root_vars.locals.provider_version
  region               = local.root_vars.locals.default_region
  resource_prefix      = local.root_vars.locals.resource_prefix
  terraform_version    = local.root_vars.locals.terraform_version
}

dependency "project" {
  config_path  = "../"
  skip_outputs = false
}

generate "providers" {
  contents  = templatefile(find_in_parent_folders("providers.tftpl"), { args = local })
  path      = "providers.tf"
  if_exists = "overwrite"
}

remote_state {
  backend = "gcs"
  config = {
    bucket = dependency.project.outputs.gcs_bucket_tfstate
    prefix = "${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = local.module_version.service_account
}

inputs = {
  display_name = "Organization Admin"
  generate_keys = true
  project_id = dependency.project.outputs.seed_project_id

  names = [
    "organization-admin",
  ]
}
