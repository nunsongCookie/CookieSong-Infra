output "external_alb_id" {
  value = aws_alb.external-alb.id
}

output "internal_alb_id" {
  value = aws_alb.internal-alb.id
}

output "web-tg-arn" {
  value = aws_lb_target_group.web-tg.arn
}

output "was-tg-arn" {
  value = aws_lb_target_group.was-tg.arn
}