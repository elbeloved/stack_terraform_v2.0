          ###################################### CLIXX RESOURCES #######################################
resource "aws_lb" "balance" {
  name                = "Stack-alb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.stack-sg.id]
  subnets             = "${aws_subnet.public_stack[*].id}"
}
 
resource "aws_lb_target_group" "balance_tg" {
  name            = "Stack-alb-tp"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.stack.id

  health_check {
    matcher             = "200"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  } 
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn     = aws_lb.balance.arn
  port                  = 80
  protocol              = "HTTP"
  default_action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.balance_tg.arn     
    } 
}     

resource "aws_launch_template" "clixx" {
  name                        = "Clixx-LC"
  image_id                    = data.aws_ami.stack_ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.stack-sg.id]
  user_data                   = base64encode(data.template_file.bootstrapCliXXASG.rendered)

  # Define EBS volumes to be attached to instances
  dynamic "block_device_mappings" {
    for_each                  = var.block_device_config

    content {
      device_name             = block_device_mappings.value.device_name

    ebs {
      volume_size             = block_device_mappings.value.volume_size
    }
    }
  }

  
  lifecycle {
    create_before_destroy     = true
  }
  
}

resource "aws_autoscaling_group" "scale" {
  name                      = var.project
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = "${aws_subnet.public_stack[*].id}"

  metrics_granularity = "1Minute"

  launch_template {
    id                      = aws_launch_template.clixx.id
    version                 = aws_launch_template.clixx.latest_version  
  }

  tag {
    key                 = "Name"
    value               = "CliXX-ASP"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.balance_tg.arn]
}

resource "aws_autoscaling_attachment" "ebs_attachment" {
  count                  = 2
  autoscaling_group_name = aws_autoscaling_group.scale.name
  lb_target_group_arn    = aws_lb_target_group.balance_tg.arn
}


        ################################## BLOG RESOURCES ###########################################

resource "aws_lb" "blog_balance" {
  name                = "Blog-alb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.stack-sg.id]
  subnets             = "${aws_subnet.public_stack[*].id}"
}

resource "aws_lb_target_group" "blog_tg" {
  name            = "Blog-alb-tp"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.stack.id

  health_check {
    matcher             = "200"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  } 
}

resource "aws_lb_listener" "front_end_blog" {
  load_balancer_arn     = aws_lb.blog_balance.arn
  port                  = 80
  protocol              = "HTTP"
  default_action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.blog_tg.arn     
    } 
}

resource "aws_autoscaling_group" "blog_scale" {
  name                      = "Blog-ASP"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = "${aws_subnet.public_stack[*].id}"
                              
  metrics_granularity = "1Minute"

  launch_template {
    id                       = aws_launch_template.Blog.id
    version                  = aws_launch_template.Blog.latest_version
  } 

  tag {
    key                 = "Name"
    value               = "Blog-ASP"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.blog_tg.arn]
}


resource "aws_launch_template" "Blog" {
  name                        = "Blog-LC"
  image_id                    = data.aws_ami.stack_ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids     = [aws_security_group.stack-sg.id]
  user_data                  = base64encode(data.template_file.bootstrapBlogASG.rendered)

  # Define EBS volumes to be attached to instances
  dynamic "block_device_mappings" {
    for_each                  = var.block_device_config

    content {
      device_name             = block_device_mappings.value.device_name

    ebs {
      volume_size             = block_device_mappings.value.volume_size
    }
    }
  }

  
  lifecycle {
    create_before_destroy     = true
  }
  
}

resource "aws_autoscaling_attachment" "ebs_attachment_blog" {
  count                  = 2
  autoscaling_group_name = aws_autoscaling_group.blog_scale.name
  lb_target_group_arn    = aws_lb_target_group.blog_tg.arn
}
