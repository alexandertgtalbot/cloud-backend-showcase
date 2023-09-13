locals {
  availability_zones         = ["a", "b", "c", ]
  default_region             = "us-east-2"
  domain                     = "refractive.space" # Update me.
  git_read_only_token        = "xxxxxxxxxx"       # Update me.
  git_branch                 = get_env("GIT_BRANCH", "main")
  management_account_id      = "087638361512" # Update me.
  resource_prefix            = "refractive"
  profile_organization_admin = "organization-admin"
  root_id                    = "r-ra4k" # Update me.
  root_ou_id                 = "r-ra4k" # Update me.
  terraform_version          = "1.5.7"

  jumpbox_deploy     = false
  jumpbox_public_key = "ssh-rsa XXXX...XXXX user@host" # Update me.

  provider_version = {
    aws        = "4.38.0"
    helm       = "2.9.0"
    kubernetes = "2.18.1"
    null       = "3.1.1"
    random     = "3.5.1"
  }

  tags = {
    contact      = "info_at_refractive.space"
    organisation = "refractive.space"
    project      = "showcase"
    team         = "platform"
  }

  module_version = {
    account       = "git::git@github.com:alexandertgtalbot/cloud-backend-showcase.git//automation/terraform/aws/account?ref=main"
    ecr           = "tfr:///terraform-aws-modules/ecr/aws?version=1.6.0"
    eks           = "tfr:///terraform-aws-modules/eks/aws?version=19.10.0"
    eks_bootstrap = "git::git@github.com:alexandertgtalbot/cloud-backend-showcase.git//automation/terraform/aws/eks_bootstrap?ref=main"
    iam_user      = "tfr:///terraform-aws-modules/iam/aws//modules/iam-user?version=5.30.0"
    ou            = "git::git@github.com:alexandertgtalbot/cloud-backend-showcase.git//automation/terraform/aws/ou?ref=main"
  }
}

inputs = {
  aws_profile                  = local.profile_organization_admin
  domain                       = local.domain
  fluxcd_git_repository_url    = "https://github.com/alexandertgtalbot/cloud-backend-showcase.git"
  fluxcd_git_repository_branch = "main"
}
