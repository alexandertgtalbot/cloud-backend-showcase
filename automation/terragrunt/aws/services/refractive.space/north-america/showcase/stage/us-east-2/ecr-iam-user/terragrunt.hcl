include "environment" {
  path ="${get_path_to_repo_root()}/automation/terragrunt/aws/includes/services.iam_user.hcl"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
