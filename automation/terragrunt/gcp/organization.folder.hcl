locals {
  # Get required variables from the root module.
  root_vars            = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  billing_account      = local.root_vars.locals.billing_account
  default_region       = local.root_vars.locals.default_region
  group_billing_admins = local.root_vars.locals.group_billing_admins
  group_org_admins     = local.root_vars.locals.group_org_admins
  labels               = local.root_vars.locals.labels
  module_version       = local.root_vars.locals.module_version
  organization         = local.root_vars.locals.organization
  org_id               = local.root_vars.locals.org_id
  provider_version     = local.root_vars.locals.provider_version
  region               = local.root_vars.locals.default_region
  resource_prefix      = local.root_vars.locals.resource_prefix
  terraform_version    = local.root_vars.locals.terraform_version

  # Use the name of the calling directory as the name of the OU.
  path = reverse(split("/", get_terragrunt_dir()))
  name = local.path[0]
}

dependency "parent" {
  config_path  = "../"
  skip_outputs = false
}

dependency "project" {
  config_path  = "${get_path_to_repo_root()}//automation/terragrunt/gcp/organization/${local.organization}"
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
    impersonate_service_account = "organization-admin@refractive-space-ef22.iam.gserviceaccount.com"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = local.module_version.folder
}

inputs = {
  names  = [ local.name ]
  parent = can(dependency.parent.outputs["seed_project_id"]) ? "key_found" : "key_not_found"
}
