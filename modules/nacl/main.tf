resource "aws_network_acl" "song-nacl-an2" {

  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids
  tags = {
    "Name" = var.name
  }
}

resource "aws_network_acl_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : "${idx}_${rule.from_port}_${rule.to_port}" => rule }

  network_acl_id = aws_network_acl.song-nacl-an2.id
  rule_number    = each.value.rule_no
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.protocol == "all" ? null : each.value.from_port
  to_port        = each.value.protocol == "all" ? null : each.value.to_port
  egress         = false # 인그레스 규칙이므로 `false`로 설정

}

resource "aws_network_acl_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : "${idx}_${rule.from_port}_${rule.to_port}" => rule }

  network_acl_id = aws_network_acl.song-nacl-an2.id
  rule_number    = each.value.rule_no
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.protocol == "all" ? null : each.value.from_port
  to_port        = each.value.protocol == "all" ? null : each.value.to_port
  egress         = true
}
