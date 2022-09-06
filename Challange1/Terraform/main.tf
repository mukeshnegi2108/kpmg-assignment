
provider aws {
  region = "us-east-1"
}

## creating security group
resource "aws_security_group" "frontend_sg" {
  name        = "webapp-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "database-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### DNS Record creation
resource "aws_route53_record" "kpmg_route53_record" {
  name    = "kpmg.interview.com"
  type    = "CNAME"
  zone_id = var.route53_zone_id
  ttl     = "300"
  records = [aws_alb.kpmg_alb.dns_name] ####
}

### Load Balancer creation
resource "aws_alb" "kpmg_alb" {
  name            = format("%s-%s", local.resource_name_prefix, "alb")
  security_groups = [aws_security_group.inbound_sg.id]
}

### Target Group creation
resource "aws_lb_target_group" "kpmg_tg" {
  deregistration_delay = 30
  name                 = "kpmg-target-group"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id

  health_check {
    port                = 8080
    path                = "/"
    matcher             = "200"
    timeout             = 5
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "kpmg_lb_listener" {
  load_balancer_arn = aws_alb.kpmg_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.kpmg_tg.arn
    type             = "forward"
  }
}

### EC2 Creation
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["self"]
}

resource "aws_instance" "frontend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.frontend.id]
  target_group_arn = [aws_lb_target_group.kpmg_tg.arn]
}

### Database Creation
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "name"
  password             = "passwordß"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
}


## using s3 to store tfstate files
terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "interview-terraform-backend-state-file"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
  }
}
