provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "server_1" {
  image_id        = "ami-0f8a61b66d1accaee"
  instance_type   = "t2.micro"
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.ingress_port} &
              EOF
  security_groups = [aws_security_group.security_group_server_1.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "security_group_server_1" {
  name = "security_group_server_1"
  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_autoscaling_group" "asg1" {
  min_size             = 1
  max_size             = 10
  name                 = "asg1"
  launch_configuration = aws_launch_configuration.server_1.name
  tag {
    key                 = "Name"
    value               = "asg_example"
    propagate_at_launch = true
  }
  vpc_zone_identifier = data.aws_subnets.default_subnet.ids
}

variable "ingress_port" {
  description = "The port for HTTP traffic"
  type        = number
  default     = 8080
}

output "sg_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.security_group_server_1.id
}

data "aws_vpc" "default_vpc" {
  default = true
}

output "subnet_id" {
	description = "We are trying to obtain the subnet_id"
	value = data.aws_vpc.default_vpc.id
}

data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}


