include "environment" {
  path ="${get_path_to_repo_root()}/automation/terragrunt/aws/includes/services.iam_user.hcl"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "iam_policy" {
  config_path  = "../ecr-iam-user-policy"
  skip_outputs = false
}

inputs = {
  policy_arns = [ dependency.iam_policy.outputs.arn ]
}