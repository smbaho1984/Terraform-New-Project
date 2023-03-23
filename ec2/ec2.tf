resource "aws_db_instance" "db" {
  identifier           = "my-db-instance"
  engine               = var.db_engine
  instance_class       = var.db_class
  allocated_storage    = var.db_allocated_storage
  name                 = var.db_name
  username             = var.db_user
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "my-db-instance"
  }
}

resource "aws_db_instance" "db_replica" {
  identifier                = "my-db-instance-replica"
  engine                    = var.db_engine
  instance_class            = var.db_class
  allocated_storage         = var.db_allocated_storage
  name                      = var.db_name
  username                  = var.db_user
  password                  = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.db_sg.id]
  source_db_instance_identifier = aws_db_instance.db.id
  copy_tags_to_snapshot     = true
  multi_az                  = true

  tags = {
    Name = "my-db-instance-replica"
  }
}

# Create launch configuration and autoscaling group
resource "aws_launch_configuration" "web_lc" {
  name_prefix          = "web-lc"
  image_id             = var.ami_id["linux"]
  instance_type       = var.instance_type[0]
  security_groups      = [aws_security_group.web_sg.id]
  key_name              = var.key_name
  user_data            = <<-EOF
              #!/bin/bash
              echo "Hello World!" > /var/www/html/index.html
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo systemctl start httpd
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
#create autoscaling group
resource "aws_autoscaling_group" "web_asg" {
  name                  = "web-asg"
  launch_configuration = aws_launch_configuration.web_lc.name
  min_size              = var.min_size
  max_size              = var.max_size
  vpc_zone_identifier   = [aws_subnet.web_a.id, aws_subnet.web_b.id]
  health_check_type     = "EC2"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }
  }



# resource "aws_autoscaling_group" "web_asg" {
#   name                  = "web-asg"
#   launch_configuration = aws_launch_configuration.web_lc.name
#   min_size              = var.min_size
#   max_size              = var.max_size
#   vpc_zone_identifier   = [aws_subnet.web_a.id, aws_subnet.web_b.id]
#   health_check_type     = "EC2"
#   health_check_grace_period = 300

#   lifecycle {
#     create_before_destroy = true
#   }

#   tag {
#     key                 = "Name"
#     value               = "web-asg"
#     propagate_at_launch = true
#   }

#   tag {
#     key                 = "Environment"
#     value               = "production"
#     propagate_at_launch = true
#   }


  # # Create autoscaling policies
  # scaling_policy {
  #   name                     = "cpu-utilization"
  #   adjustment_type          = "ChangeInCapacity"
  #   estimated_instance_warmup = 300
  #   target_tracking_configuration {
  #     predefined_metric_spec {
  #       predefined_metric_type = "ASGAverageCPUUtilization"
  #       target_value           = 80.0
  #     }
  #   }
  # }

  # Scale in when CPU utilization drops below 30%
  # scaling_policy {
  #   name                     = "cpu-idle"
  #   adjustment_type          = "ChangeInCapacity"
  #   estimated_instance_warmup = 300
  #   target_tracking_configuration {
  #     predefined_metric_spec {
  #       predefined_metric_type = "ASGAverageCPUUtilization"
  #       target_value           = 30.0
  #     }
  #   }
  # }

# Create an Alarm with Cloudwatch for scaling out
# Scaling out Alarm when CPU utilization is greater than 80%
resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80.0
  alarm_description   = "Scale out if CPU utilization >= 80%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  } 
}

# Create an Alarm with Cloudwatch for scaling in
# Scaling in Alarm when CPU utilization is less than 30%
resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30.0
  alarm_description   = "Scale in if CPU utilization <= 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
  
  alarm_actions = [
    aws_autoscaling_policy.my_autoscaling_policy.arn
  ]
}











#   # Create autoscaling policy
#   scaling_policy {
#     name           = "cpu-utilization"
#     adjustment_type = "ChangeInCapacity"
#     estimated_instance_warmup = 300
#     target_tracking_configuration {
#       predefined_metric_spec {
# predefined_metric_type = "ASGAverageCPUUtilization"
#       target_value           = 80.0
#     }

#     # Scale in when CPU utilization drops below 30%
#     scaling_policy {
#       name           = "cpu-idle"
#       adjustment_type = "ChangeInCapacity"
#       estimated_instance_warmup = 300
#       target_tracking_configuration {
#         predefined_metric_spec {
#           predefined_metric_type = "ASGAverageCPUUtilization"
#           target_value           = 30.0
#         }
#       }
#     }
#   }
#   }
#  #Create an Alarm with Cloudwatch for scaling out
# # Scaling out Alarm when CPU utilization is greater than 80%
# resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
#   alarm_name          = "scale-out-alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 2
#  metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 80.0
#   alarm_description   = "Scale out if CPU utilization >= 80%"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web_asg.name
#   } 
# }

# #Create an Alarm with Cloudwatch for scaling in
# # Scaling in Alarm when CPU utilization is less than 30%
# resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
#   alarm_name          = "scale-in-alarm"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 30.0
#   alarm_description   = "Scale in if CPU utilization <= 30%"
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web_asg.name
#   }
  
#   alarm_actions = [
#     aws_autoscaling_policy.my_autoscaling_policy.arn
#   ]
# }
 