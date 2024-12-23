# private web target group
resource "aws_lb_target_group" "web-tg" {
  target_type      = "instance"
  name             = "song-web-target-group-an2"
  port             = 3000
  ip_address_type  = "ipv4"
  protocol         = "HTTP"
  vpc_id           = var.vpc_id
  protocol_version = "HTTP1"

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/health"
  }

    tags = {
    Resource = "web-target-group"
  }
}

resource "aws_lb_target_group_attachment" "web-tg-att" {
  for_each = {
    for k, v in ec2-instance-ids : # ec2 생성 후 추가 필요
    k => v
  }
  target_group_arn = aws_lb_target_group.web-tg.arn
  target_id        = each.value.id
}

# private was target group
resource "aws_lb_target_group" "was-tg" {
  target_type      = "instance"
  name             = "song-was-target-group-an2"
  port             = 8080
  ip_address_type  = "ipv4"
  protocol         = "HTTP"
  vpc_id           = var.vpc_id
  protocol_version = "HTTP1"

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/actuator/health"
  }

  tags = {
    Resource = "was-target-group"
  }
}

resource "aws_lb_target_group_attachment" "was-tg-att" {
  for_each = {
    for k, v in var.ec2-instance-ids :
    k => v
  }
  target_group_arn = aws_lb_target_group.was-tg.arn
  target_id        = each.value.id
}

# external ALB
resource "aws_alb" "external-alb" {
  name            = "song-external-alb-an2"
  internal        = false
  security_groups = [var.security-group-id] # 생성 후 추가 필요
  subnets         = [var.public_subnet_id[0], var.public_subnet_id[1]]
}

resource "aws_alb_listener" "external-alb-listner" {
  load_balancer_arn = aws_alb.external-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.song-web-tg.arn
  }
}

# internal ALB
resource "aws_alb" "internal-alb" {
  name            = "song-internal-alb-an2-az1"
  internal        = true
  security_groups = [var.security-group-id] # 생성 후 추가 필요
  subnets         = [var.private_was_subnet_ids[0], var.private_was_subnet_ids[1]]
}

resource "aws_alb_listener" "internal-alb-listner" {
  load_balancer_arn = aws_alb.internal-alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was-tg.arn
  }
}

# External ALB에 HTTPS 리스너 추가
resource "aws_alb_listener" "external-alb-https-listener" {
  load_balancer_arn = aws_alb.external-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn 
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

# HTTP to HTTPS redirection
resource "aws_alb_listener" "external-alb-http-listener" {
  load_balancer_arn = aws_alb.external-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}