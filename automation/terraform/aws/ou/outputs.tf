output "arn" {
  value = aws_organizations_organizational_unit.this.arn
}

output "id" {
  value = aws_organizations_organizational_unit.this.id
}

output "name" {
  value = var.name
}

output "policy_prefix" {
  value = local.policy_prefix
}
