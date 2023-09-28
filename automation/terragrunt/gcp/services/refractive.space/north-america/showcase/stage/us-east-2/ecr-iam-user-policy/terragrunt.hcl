include "environment" {
  path ="${get_path_to_repo_root()}/automation/terragrunt/aws/includes/services.iam_policy.hcl"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}