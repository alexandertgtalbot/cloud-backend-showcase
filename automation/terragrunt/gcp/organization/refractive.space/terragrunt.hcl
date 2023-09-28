include "bootstrap" {
  path = find_in_parent_folders("organization.bootstrap.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
