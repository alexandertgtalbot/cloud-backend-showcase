include "environment" {
  path ="${get_path_to_repo_root()}/automation/terragrunt/aws/includes/services.eks.hcl"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  subnet_ids = [
    "subnet-02cdd4e225ef38b36",
    "subnet-0b47dc5b9c1923765",
    "subnet-0fbc4f51d95bdc662",
  ]

  vpc_id = "vpc-0832094940acba2b1"
}