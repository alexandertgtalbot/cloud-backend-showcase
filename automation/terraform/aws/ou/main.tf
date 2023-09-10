/*
* # Proof of Concept AWS Organizational Unit module
*/

locals {
  include_service_control_policy = var.service_control_policy != ""
  include_tag_policy             = var.tag_policy != ""
  normalised_name                = replace(lower(var.name), " ", "-")
  policy_prefix                  = trimprefix(replace("${var.policy_prefix}-${local.normalised_name}", "--", "-"), "-")
}

resource "aws_organizations_organizational_unit" "this" {
  name      = var.name
  parent_id = var.parent_id
}

resource "aws_organizations_policy" "service_control_policy" {
  content = var.service_control_policy
  count   = local.include_service_control_policy ? 1 : 0
  name    = "${local.policy_prefix}-scp"
  type    = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "service_control_policy" {
  count     = local.include_service_control_policy ? 1 : 0
  policy_id = aws_organizations_policy.service_control_policy[count.index].id
  target_id = aws_organizations_organizational_unit.this.id
}

resource "null_resource" "delete_default_policy" {
  count      = local.include_service_control_policy ? 1 : 0
  depends_on = [aws_organizations_organizational_unit.this]
}

resource "aws_organizations_policy" "tag_policy" {
  content = var.tag_policy
  count   = local.include_tag_policy ? 1 : 0
  name    = "${local.policy_prefix}-tp"
  type    = "TAG_POLICY"
}

resource "aws_organizations_policy_attachment" "tag_policy" {
  count     = local.include_tag_policy ? 1 : 0
  policy_id = aws_organizations_policy.tag_policy[count.index].id
  target_id = aws_organizations_organizational_unit.this.id
}
