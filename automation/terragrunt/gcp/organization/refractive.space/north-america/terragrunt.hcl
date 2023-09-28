include "folder" {
  path = find_in_parent_folders("organization.folder.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
