resource "aws_launch_template" "web-launch-template" {
  name          = "song-web-launch-template"
  description   = "Web prod용 EC2 서버"
  image_id      = "ami-0dd9237a04e008613" # ubuntu 24.04 LTS 64비트(x86)
  instance_type = "t2.micro"

  user_data = base64encode("${path.module}/web_server.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.sg-id]
  }
  iam_instance_profile {
    name = var.role-name
  }

  tags = {
    Name     = "web-launch-template"
    Resource = "web-launch-template"
  }

  monitoring {
    enabled = true
  }
}

resource "aws_launch_template" "was-launch-template" {
  name          = "song-was-launch-template"
  image_id      = "ami-0dd9237a04e008613" # ubuntu 24.04 LTS 64비트(x86)
  instance_type = "t2.micro"

  user_data = base64encode("${path.module}/was_server.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.sg-id]
  }
  iam_instance_profile {
    name = var.role-name
  }

  tags = {
    Name     = "was-launch-template"
    Resource = "was-launch-template"
  }

  monitoring {
    enabled = true
  }
}

# ASG1 WEB
resource "aws_autoscaling_group" "web-asg" {
  name                      = "song-web-asg-an2"
  vpc_zone_identifier       = var.private_web_subnet_ids
  target_group_arns         = [var.web-tg-arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2

  launch_template {
    id      = aws_launch_template.web-launch-template.id
    version = "$Latest"
  }
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"

  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 110
  }

  dynamic "tag" {
    for_each = {
      Name     = "web-ec2"
      Resource = "web-asg"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "web_cpu_policy" {
  name                   = "web-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.web-asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# ASG2 WAS
resource "aws_autoscaling_group" "was-asg" {
  name                      = "song-was-asg-an2"
  vpc_zone_identifier       = var.private_was_subnet_ids
  target_group_arns         = [var.was-tg-arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2

  launch_template {
    id      = aws_launch_template.was-launch-template.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"

  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 110
  }

  dynamic "tag" {
    for_each = {
      Name     = "was-ec2"
      Resource = "was-asg"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "was_cpu_policy" {
  name                   = "was-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.was-asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}