variable "billing_access" {
  default = "DENY"
  type    = string

  validation {
    condition     = contains(["ALLOW", "DENY"], var.billing_access)
    error_message = "billing_access must be either ALLOW or DENY"
  }
}

variable "email" {
  type = string
}

variable "name" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "role_name" {
  default = "bootstrapper"
  type    = string
}
