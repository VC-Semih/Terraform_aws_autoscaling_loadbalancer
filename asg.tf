resource "aws_launch_template" "lc" {
  name                   = "${var.vpc_name}-lc"
  image_id               = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = "deployer-key-2"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.vpc_name}-lc"
    }
  }
  user_data = filebase64("${path.module}/deploy.sh")
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [for subnet in module.discovery.private_subnets : subnet]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  target_group_arns = [aws_lb_target_group.alb-http.arn]
  launch_template {
    id      = aws_launch_template.lc.id
    version = "$Latest"
  }
}