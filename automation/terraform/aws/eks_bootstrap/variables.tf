variable "aws_auth_roles" {
  type    = list(any)
  default = []
}

variable "aws_auth_users" {
  type    = list(any)
  default = []
}

variable "aws_auth_accounts" {
  type    = list(any)
  default = []
}

variable "fluxcd_git_repository_url" {
  type = string
}

variable "fluxcd_git_repository_branch" {
  type = string
}

variable "fluxcd_git_repository_path" {
  type = string
}

variable "oidc_provider" {
  type = string
}
