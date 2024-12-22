variable "name" {
  description = "The name of the Security Group"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to which the Security Group belongs"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port                    = number
    to_port                      = number
    protocol                     = string
    cidr_ipv4                    = string
    referenced_security_group_id = string
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port                    = number
    to_port                      = number
    protocol                     = string
    cidr_ipv4                    = string
    referenced_security_group_id = string
  }))

  default = []
}

variable "tags" {
  description = "Tags for the Security Group"
  type        = map(string)
  default     = {}
}
