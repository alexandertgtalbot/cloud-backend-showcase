dependency "parent" {
  config_path  = "../"
  skip_outputs = false
}

include "ou" {
  path = find_in_parent_folders("organization.ou.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  parent_id = dependency.parent.outputs.id
}
