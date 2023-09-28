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

generate "providers" {
  contents  = templatefile(find_in_parent_folders("providers.tftpl"), { args = local })
  path      = "providers.tf"
  if_exists = "overwrite"
}

remote_state {
  backend = "http"
  config = {
    address        = "https://api.tfstate.dev/github/v1"
    lock_address   = "https://api.tfstate.dev/github/v1/lock"
    unlock_address = "https://api.tfstate.dev/github/v1/lock"
    lock_method    = "PUT"
    unlock_method  = "DELETE"
    username       = "alexandertgtalbot/cloud-backend-showcase"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = local.module_version.bootstrap
}

inputs = {
  activate_apis = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]

  billing_account            = local.billing_account
  default_region             = local.default_region
  encrypt_gcs_bucket_tfstate = true
  force_destroy              = true
  group_billing_admins       = local.group_billing_admins
  group_org_admins           = local.group_org_admins
  kms_prevent_destroy        = false
  org_id                     = local.org_id
  project_id                 = local.resource_prefix
  project_labels             = local.labels
  project_prefix             = local.resource_prefix
  storage_bucket_labels      = local.labels
  create_terraform_sa        = false
}
