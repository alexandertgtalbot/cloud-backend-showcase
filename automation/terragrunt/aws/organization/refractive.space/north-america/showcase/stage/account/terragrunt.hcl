include "ou" {
  path = find_in_parent_folders("organization.account.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
