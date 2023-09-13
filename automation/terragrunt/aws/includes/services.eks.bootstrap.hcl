locals {
  # Get general variables.
  root_vars       = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  # account_id      = local.root_vars.locals.account_id
  default_region  = local.root_vars.locals.default_region
  # iam_role        = local.root_vars.locals.iam_role
  module_version  = local.root_vars.locals.module_version
  profile         = "todo"

  # resource_prefix = local.root_vars.locals.resource_prefix
  # vpc_id          = local.root_vars.locals.vpc_id

  # # Get environmental identifiers from parent directories.
  # path        = reverse(split("/", get_terragrunt_dir()))
  # service     = local.path[1]
  # region      = local.path[2]
  # environment = local.path[3]
  # area        = local.path[4]

  # Get environmental identifiers from parent directories.
  path         = reverse(split("/", get_terragrunt_dir()))
  service      = local.path[1]
  region       = local.path[2]
  environment  = local.path[3]
  project      = local.path[4]
  territory    = local.path[5]
  organization = local.path[6]

  # region_resource_prefix       = "${local.resource_prefix}-${local.environment}-${local.region}"
  terraform_required_providers = false
  eks_cluster_name             = "eks"

  tags = merge(local.root_vars.locals.tags, {
    environment = local.environment
    region      = local.region
    territory   = local.territory
  })
}

dependency "account" {
  config_path  = "../../../../../../../../organization/${local.organization}/${local.territory}/${local.project}/${local.environment}/account"
  skip_outputs = false
}

dependency "eks" {
  config_path  = "../"
  skip_outputs = false
}

generate "providers" {
  contents = templatefile(find_in_parent_folders("providers.tftpl"), {
    args = merge(
      local,
      {
        eks = {
          cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
          cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
          cluster_name                       = dependency.eks.outputs.cluster_name
        }
        iam_role = "arn:aws:iam::${dependency.account.outputs.id}:role/${dependency.account.outputs.role_name}"
      }
    )
  })
  path      = "providers.tf"
  if_exists = "overwrite"
}

remote_state {
  backend = "s3"

  config = {
    acl      = "private"
    bucket   = "${dependency.account.outputs.name}-terraform-state"
    encrypt  = true
    key      = "terragrunt/${get_path_from_repo_root()}/terraform.tfstate"
    region   = local.default_region
    role_arn = "arn:aws:iam::${dependency.account.outputs.id}:role/${dependency.account.outputs.role_name}"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  source = local.module_version.eks_bootstrap
}

inputs = {
  fluxcd_git_repository_path   = "./automation/kubernetes/${local.environment}"
  oidc_provider                = dependency.eks.outputs.oidc_provider
}
