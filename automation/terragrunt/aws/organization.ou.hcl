locals {
  # Get required variables from the root module.
  root_vars         = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  region            = local.root_vars.locals.default_region
  resource_prefix   = local.root_vars.locals.resource_prefix
  root_ou_id        = local.root_vars.locals.root_ou_id
  tags              = local.root_vars.locals.tags
  module_version    = local.root_vars.locals.module_version
  provider_version  = local.root_vars.locals.provider_version
  terraform_version = local.root_vars.locals.terraform_version

  # Use the name of the calling directory as the name of the OU.
  path = reverse(split("/", get_terragrunt_dir()))
  name = local.path[0]

  requested_region = jsonencode({ "aws:RequestedRegion" : try(lookup(local.root_vars.locals.regions, local.name), []) })
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
  source = local.module_version.ou
}

inputs = {
  name                   = local.name
  service_control_policy = fileexists("${get_terragrunt_dir()}/service_control_policy.json.tftpl") ? templatefile("${get_terragrunt_dir()}/service_control_policy.json.tftpl", { args = local }) : ""
  tag_policy             = fileexists("${get_terragrunt_dir()}/tag_policy.json") ? file("${get_terragrunt_dir()}/tag_policy.json") : ""
}
