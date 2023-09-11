/*
* # Proof of Concept AWS Account Module
*/

resource "aws_organizations_account" "this" {
  email                      = var.email
  iam_user_access_to_billing = var.billing_access
  name                       = replace(lower(var.name), " ", "-")
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
