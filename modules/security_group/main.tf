resource "aws_security_group" "song-sg-an2" {
  name   = var.name
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id            = aws_security_group.song-sg-an2.id
  for_each                     = { for idx, rule in var.ingress_rules : "${idx}_${rule.from_port}_${rule.to_port}" => rule }
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = each.value.cidr_ipv4 != null ? each.value.cidr_ipv4 : null
  referenced_security_group_id = each.value.referenced_security_group_id != null ? each.value.referenced_security_group_id : null
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id            = aws_security_group.song-sg-an2.id
  for_each                     = { for idx, rule in var.egress_rules : "${idx}_${rule.from_port}_${rule.to_port}" => rule }
  from_port                    = each.value.protocol == "all" ? null : each.value.from_port
  to_port                      = each.value.protocol == "all" ? null : each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = each.value.cidr_ipv4 != null ? each.value.cidr_ipv4 : null
  referenced_security_group_id = each.value.referenced_security_group_id != null ? each.value.referenced_security_group_id : null
}
