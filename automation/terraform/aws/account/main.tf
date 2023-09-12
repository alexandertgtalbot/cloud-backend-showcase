/*
* # Proof of Concept AWS Account Module
*/

locals {
  email = var.email == "" ? "${random_uuid.name.id}@${var.domain}" : var.email
  name  = var.name == "" ? random_uuid.name.id : var.name
}

resource "random_uuid" "name" {}

resource "aws_organizations_account" "this" {
  email                      = local.email
  iam_user_access_to_billing = var.billing_access
  name                       = local.name
  parent_id                  = var.parent_id
  role_name                  = var.role_name

  lifecycle {
    ignore_changes = [
      email,
      iam_user_access_to_billing,
      name,
      role_name,
    ]

    prevent_destroy = true
  }
}
