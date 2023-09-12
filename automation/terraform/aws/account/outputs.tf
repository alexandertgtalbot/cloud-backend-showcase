output "email" {
  value = local.email
}

output "id" {
  value = aws_organizations_account.this.id
}

output "name" {
  value = local.email
}

output "role_name" {
  value = var.role_name
}
