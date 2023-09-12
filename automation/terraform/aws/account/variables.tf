variable "billing_access" {
  default = "DENY"
  type    = string

  validation {
    condition     = contains(["ALLOW", "DENY"], var.billing_access)
    error_message = "billing_access must be either ALLOW or DENY"
  }
}

variable "domain" {
  type    = string
  default = ""
}

variable "email" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "parent_id" {
  type = string
}

variable "role_name" {
  default = "bootstrapper"
  type    = string
}
