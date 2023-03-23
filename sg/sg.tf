# Create security groups
#create load balancer security group
resource "aws_security_group" "lb_sg" {
  name_prefix = "lb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.lb_sg_name
  }
  }

#create web tier security group: incoming traffic from lb_sg
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  tags = {
    Name = var.web_sg_name
  }
}

#create database security group==>incoming traffic from web_sg
resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = var.db_sg_name
  }
}

