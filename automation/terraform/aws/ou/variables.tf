variable "name" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "policy_prefix" {
  default = ""
  type    = string
}

variable "service_control_policy" {
  default = ""
  type    = string
}

variable "tag_policy" {
  default = ""
  type    = string
}
