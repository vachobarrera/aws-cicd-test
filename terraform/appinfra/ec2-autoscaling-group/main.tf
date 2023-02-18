# Ami definition ========================================================

data "aws_ami" "mytest_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230208"]
  }
}

# Launc template ========================================================

resource "aws_launch_template" "mytest_launch_template" {
  name = "${var.project_name}_launch_template"
  image_id = "ami-0557a15b87f6559cf"
  instance_type = var.instance_type
  key_name = "${var.project_name}_ssh_key"
  user_data = "${base64encode(file("preparevm.sh"))}"
  #vpc_security_group_ids = [aws_security_group.mytest_security_group.id]
  tags = {
    Name = "${var.project_name}_launch_template"
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.mytest_security_group.id]
  }
}

# Auto Scaling Group ========================================================

resource "aws_autoscaling_group" "mytest_asg" {
  name = "${var.project_name}_asg"
  vpc_zone_identifier = [aws_subnet.mytest_subnet_1.id,aws_subnet.mytest_subnet_2.id]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  target_group_arns     = ["${aws_lb_target_group.mytest_target_group.arn}"]
  health_check_type         = "ELB"
  health_check_grace_period = 5

  launch_template {
    id      = aws_launch_template.mytest_launch_template.id
    version = "$Latest"
  }
  
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Auto Scaling Policies ========================================================

resource "aws_autoscaling_policy" "mytest_scale_up_policy" {
  name                   = "${var.project_name}_scale_up_policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mytest_asg.name
}

resource "aws_autoscaling_policy" "mytest_scale_down_policy" {
  name                   = "${var.project_name}_scale_down_policy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mytest_asg.name
}

# Scaling alarms ========================================================

resource "aws_cloudwatch_metric_alarm" "mytest_scale_up_alarm" {
  alarm_name          = "${var.project_name}_scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "80"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.mytest_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.mytest_scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "mytest_scale_down_alarm" {
  alarm_name          = "${var.project_name}_scale_down_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "20"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.mytest_asg.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.mytest_scale_down_policy.arn]
}