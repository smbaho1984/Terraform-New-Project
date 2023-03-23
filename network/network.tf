# Create VPC and subnets
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet_a_cidr_block
  availability_zone = var.availability_zone[0]
}

resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet_a_cidr_block
  availability_zone = var.availability_zone[1]
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_a_cidr_block
  availability_zone =  var.availability_zone[0]
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_b_cidr_block
  availability_zone = var.availability_zone[1]
}



# Create internet gateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

#create public route table for web tier
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.gw.id
   # destination    = "internet"
  }

  tags = {
    Name = "web-rt"
  }
}

#create private route table for db tier
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "db-rt"
  }
}

# Associate subnets with route tables
#Associate subnet Web_a with public Route table web
resource "aws_route_table_association" "web_a" {
  subnet_id      = aws_subnet.web_a.id
  route_table_id = aws_route_table.web.id
}

#Associate subnet Web_b with public Route table web
resource "aws_route_table_association" "web_b" {
  subnet_id      = aws_subnet.web_b.id
  route_table_id = aws_route_table.web.id
}

#Associate subnet db_a with private Route table db
resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.db.id
}

#Associate subnet db_b with private Route table db
resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.db.id
}



# Create RDS resources
#create db_subnet_group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]
}


# Create internal load balancer
resource "aws_lb" "internal" {
  #name               = internal-lb
  internal           = true
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id = aws_subnet.web_a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.web_b.id
  }

  tags = {
    Name = "internal-lb"
  }
}


#create load balancer target group (Web_a and Web_b)
# Create target groups
resource "aws_lb_target_group" "web_a" {
  #name_prefix = "web-a-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-a-tg"
  }
}

resource "aws_lb_target_group" "web_b" {
  #name_prefix = "web-a-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-b-tg"
  }
}

# Create listeners network load balancer listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.web_a.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 443
  protocol          = "TLS"

  default_action {
    target_group_arn = aws_lb_target_group.web_a.arn
    type = "forward"
  }
  }
