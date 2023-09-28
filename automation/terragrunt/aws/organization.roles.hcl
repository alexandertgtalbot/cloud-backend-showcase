locals {
  role_path = get_terragrunt_dir()

  policies = {
    resident = "${local.role_path}/common/policies/resident"
  }
}
