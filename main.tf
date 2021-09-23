### Provider definition

module "discovery" {
  source         = "github.com/Lowess/terraform-aws-discovery.git"
  aws_region     = var.aws_region
  vpc_name       = var.vpc_name
  ec2_ami_names  = ["amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2"]
  ec2_ami_owners = "amazon"
}

resource "aws_security_group" "alb_sg" {
  name        = "lb-sg"
  description = "Security group for load balancer"
  vpc_id      = module.discovery.vpc_id
  tags = {
    Name = "${var.vpc_name}-loadbalancer-securitygroup"
  }
}

resource "aws_security_group_rule" "alb_egress" {
  type        = "egress"
  description = "Alb egress rule"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_ingress" {
  type        = "ingress"
  description = "Alb ingress rule"
  from_port   = 80
  to_port     = 80
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group" "asg_sg" {
  name = "asg-sg"
  description = "Security group for auto scaling group"
  vpc_id      = module.discovery.vpc_id
  tags = {
    Name = "${var.vpc_name}-autoscalinggroup-securitygroup"
  }
}

resource "aws_security_group_rule" "asg_egress" {
  type        = "egress"
  description = "Asg egress rule"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg_sg.id
}

resource "aws_security_group_rule" "asg_ingress" {
  type        = "ingress"
  description = "Asg ingress rule"
  from_port   = 8080
  to_port     = 8080
  protocol    = "TCP"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id = aws_security_group.asg_sg.id
}

data "aws_ami" "amazonlinux" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.2021*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgb4KJX+Rtdm4rfAllGeviFxt1ONlj8zwbHaaoCIbpBr52re3xT1LND/tiQyool0qL9iZQIjd89//EPXNzlvNPXM+XJhN5A2zgTmHanAoJt+6N6LDJRCUYfRI9ooJzkWsraB7IqAPe1/lxb8OH0LZjS+OYoGn/0zVzlEeKZlSJSSf+GF98AHKcWxvUVpU/E++Q7fmsHdCCYDzxf6SGpUzgVC+WiIJN/u+c2uAIF0ZJ/mdgBZhOi85ISuVfnXeYKvxVfZry7jsLjVCJrLOBBdWCY5twHgsCdjKWDqkfVRVNoam/2e+QKsJnyxg8ajlYLVrQCiIXgf9S6KjMc4VtvOqP"
}

output "discorvery_output" {
  value = module.discovery
}
### Module Main

