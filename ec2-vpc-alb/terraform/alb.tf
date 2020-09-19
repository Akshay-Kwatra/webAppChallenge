
# Specifying aws as a provider
provider "aws" {
  region = var.region
}

# Data Sources to fetch existing resources in your aws account.

data "aws_caller_identity" "current" {}


data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "subnet_ids" {
  tags = {
    Name = var.subnet_prefix
  }

  vpc_id = data.aws_vpc.vpc.id
}

data "aws_security_group" "http" {
  filter {
    name   = "tag:Name"
    values = [var.security_group]
  }

  vpc_id = data.aws_vpc.vpc.id
}

# Application Load Balancer to distribute load between Apache and Nginx Servers.

resource "aws_lb" "lb" {
  internal           = "false"
  load_balancer_type = "application"
  name               = "${var.name}-lb"
  subnets            = data.aws_subnet_ids.subnet_ids.ids
  security_groups    = [data.aws_security_group.http.id]

  tags = {
    Name        = var.name
  }
}

# Application Load Balancer Target Groups

resource "aws_lb_target_group" "target_group" {
  name              = "${var.name}-target-group"
  port              = 8080
  protocol          = "HTTP"
  proxy_protocol_v2 = false
  vpc_id            = data.aws_vpc.vpc.id
  target_type       = "instance"

# Health checks to be configured for the targets from the Load Balancer

  health_check {
    healthy_threshold   = 2
    interval            = 30
    port                = 8080
    protocol            = "HTTP"
    unhealthy_threshold = 5
  }

  tags = {
    Name        = "${var.name}"
  }
}

# Application Load Balancer Listener Resource

resource "aws_lb_listener" "lb_listener" {
  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate
}
