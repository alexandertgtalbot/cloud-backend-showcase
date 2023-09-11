locals {
  availability_zones         = ["a", "b", "c", ]
  domain                     = "refractive.space" # Update me.
  git_read_only_token        = "xxxxxxxxxx" # Update me.
  git_branch                 = get_env("GIT_BRANCH", "main")
  management_account_id      = "087638361512" # Update me.
  resource_prefix            = "refractive"
  profile_organization_admin = "organization-admin"
  region                     = "us-east-2"
  root_id                    = "r-ra4k" # Update me.
  root_ou_id                 = "r-ra4k" # Update me.
  terraform_version          = "1.5.7"

  jumpbox_deploy     = false
  jumpbox_public_key = "ssh-rsa XXXX...XXXX user@host" # Update me.

  provider_version = {
    aws  = "4.38.0"
    null = "3.1.1"
  }

  tags = {
    contact      = "info_at_refractive.space"
    organisation = "refractive"
    project      = "showcase"
    team         = "platform"
  }

  module_version = {
    ou      = "git::git@github.com:alexandertgtalbot/cloud-backend-showcase.git//automation/terraform/aws/ou?ref=main"
    account = "git::git@github.com:alexandertgtalbot/cloud-backend-showcase.git//automation/terraform/aws/account?ref=main"
  }
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

inputs = {
  aws_profile = local.profile_organization_admin
  domain      = local.domain
}
