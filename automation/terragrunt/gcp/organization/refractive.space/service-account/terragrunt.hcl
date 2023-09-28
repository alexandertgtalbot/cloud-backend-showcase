include "organization" {
  path = find_in_parent_folders("organization.service-account.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
