
# VPC ========================================================

resource "aws_vpc" "mytest_vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}_vpc"
  }
}

# Subnets ========================================================

resource "aws_subnet" "mytest_subnet_1" {
  vpc_id     = aws_vpc.mytest_vpc.id
  cidr_block  =  "172.31.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}_subnet_1"
  }
}

resource "aws_subnet" "mytest_subnet_2" {
  vpc_id     = aws_vpc.mytest_vpc.id
  cidr_block  =  "172.31.10.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}_subnet_2"
  }
}

# gateway ========================================================

resource "aws_internet_gateway" "mytest_ig" {
  vpc_id = "${aws_vpc.mytest_vpc.id}"
  tags = {
    Name = "${var.project_name}_ig"
  }
}

# Route table ========================================================

resource "aws_route_table" "mytest_rt" {
  vpc_id = aws_vpc.mytest_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mytest_ig.id
  }

  tags = {
    Name = "${var.project_name}_rt"
  }
}

resource "aws_route_table_association" "mytest_association_subnet_1" {
  subnet_id      = aws_subnet.mytest_subnet_1.id
  route_table_id = aws_route_table.mytest_rt.id
}

resource "aws_route_table_association" "mytest_association_subnet_2" {
  subnet_id      = aws_subnet.mytest_subnet_2.id
  route_table_id = aws_route_table.mytest_rt.id
}

# ALB ========================================================

resource "aws_lb" "mytest_alb" {
  name                = "mytestalb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.mytest_security_group.id]
  subnets             = [aws_subnet.mytest_subnet_1.id,aws_subnet.mytest_subnet_2.id]
}

resource "aws_lb_target_group" "mytest_target_group" {
  name     = "mytest-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.mytest_vpc.id
  
}

resource "aws_lb_listener" "mytest_listener" {
  load_balancer_arn = aws_lb.mytest_alb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_lb_target_group.mytest_target_group.arn
    type             = "forward"
  }
}