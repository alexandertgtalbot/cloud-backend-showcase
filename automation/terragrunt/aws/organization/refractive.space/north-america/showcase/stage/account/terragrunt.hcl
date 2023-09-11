dependency "parent" {
  config_path  = "../"
  skip_outputs = false
}

include "ou" {
  path = find_in_parent_folders("organization.account.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  email     = "acme-north-america-dev-mev-boost-relay@refractive.space"
  parent_id = dependency.parent.outputs.id
}
