locals {
  # Get general variables.
  root_vars         = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  default_region    = local.root_vars.locals.default_region
  module_version    = local.root_vars.locals.module_version
  provider_version  = local.root_vars.locals.provider_version
  terraform_version = local.root_vars.locals.terraform_version

  # Get environmental identifiers from parent directories.
  path         = reverse(split("/", get_terragrunt_dir()))
  repository   = local.path[0]
  service      = local.path[1]
  region       = local.path[2]
  environment  = local.path[3]
  project      = local.path[4]
  territory    = local.path[5]
  organization = local.path[6]

  region_resource_prefix       = "${local.project}-${local.environment}-${local.region}"
  terraform_required_providers = false

  tags = merge(local.root_vars.locals.tags, {
    environment = local.environment
    region      = local.region
    repository  = local.repository
    service     = local.service
    territory   = local.territory
  })
}

dependency "account" {
  config_path  = "../../../../../../../../organization/${local.organization}/${local.territory}/${local.project}/${local.environment}/account"
  skip_outputs = false
}

dependency "ecr_iam_user" {
  config_path  = "../../ecr-iam-user"
  skip_outputs = false
}

generate "providers" {
  contents = templatefile(find_in_parent_folders("providers.tftpl"), { args = merge(local, {
    iam_role = "arn:aws:iam::${dependency.account.outputs.id}:role/${dependency.account.outputs.role_name}"
  }) })
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
  source = local.module_version.ecr
}

inputs = {
  repository_name = local.repository

  repository_read_write_access_arns = [
    "arn:aws:iam::${dependency.account.outputs.id}:role/${dependency.account.outputs.role_name}",
    dependency.ecr_iam_user.outputs.iam_user_arn
  ]

  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.tags
}
