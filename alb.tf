resource "aws_lb" "alb-public" {
  name               = "${var.vpc_name}-alb-public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.discovery.public_subnets

  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Name        = "${var.vpc_name}-alb-public"
  }
}

resource "aws_lb_target_group" "alb-http" {
  name     = "${var.vpc_name}-alb-http"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.discovery.vpc_id
}

resource "aws_lb_listener" "alb-http" {
  load_balancer_arn = aws_lb.alb-public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-http.arn
  }
}