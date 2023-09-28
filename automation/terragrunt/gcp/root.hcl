locals {
  availability_zones         = ["a", "b", "c", ]
  billing_account            = "017489-054183-AB09E5" # Update me.
  default_region             = "us-east1"
  domain                     = "refractive.space" # Update me.
  git_branch                 = get_env("GIT_BRANCH", "main")
  git_read_only_token        = "xxxxxxxxxx"       # Update me.
  group_org_admins           = "gcp-organization-admins@refractive.space"
  group_billing_admins       = "gcp-billing-admins@refractive.space"
  organization               = "refractive.space" # Update me.
  org_id                     = "304575270323" # Update me.
  profile_organization_admin = "organization-admin"
  resource_prefix            = "refractive-space"
  terraform_version          = "1.5.7"

  provider_version = {
    gcp        = "4.83.0"
    helm       = "2.9.0"
    kubernetes = "2.18.1"
    null       = "3.1.1"
    random     = "3.5.1"
  }

  labels = {
    contact      = "info-at-refractive-space"
    organisation = "refractive-space"
    project      = "showcase"
    team         = "platform"
  }

  module_version = {
    bootstrap       = "tfr:///terraform-google-modules/bootstrap/google?version=6.4.0"
    folder          = "tfr:///terraform-google-modules/folders/google?version=4.0.0"
    project         = "tfr:///terraform-google-modules/project-factory/google?version=14.3.0"
    service_account = "tfr:///terraform-google-modules/service-accounts/google?version=4.2.1"
  }
}

inputs = {
  domain                       = local.domain
  fluxcd_git_repository_branch = "main"
  fluxcd_git_repository_url    = "https://github.com/alexandertgtalbot/cloud-backend-showcase.git"
}
