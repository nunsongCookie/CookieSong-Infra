variable "name" {
  type = string
}

variable "vpc_id" {
  description = "The VPC ID to which the Security Group belongs"
  type        = string
}

variable "ingress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = number
    rule_action = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))

  default = []
}

variable "egress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = number
    rule_action = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))

  default = []
}
