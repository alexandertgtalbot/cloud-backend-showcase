output "email" {
  value = var.name
}

output "id" {
  value = aws_organizations_account.this.id
}

output "name" {
  value = var.name
}

output "role_name" {
  value = var.role_name
}
