provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server_1" {
  ami = "ami-0f8a61b66d1accaee"
  instance_type = "t2.micro"
  tags = {
	Name = "server_1"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.ingress_port} &
              EOF
  user_data_replace_on_change = true 
  vpc_security_group_ids = [aws_security_group.security_group_server_1.id]
}

resource "aws_security_group" "security_group_server_1" {
	name = "security_group_server_1"
	ingress {
		from_port = var.ingress_port
		to_port = var.ingress_port
 		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]	
	}
	
}

variable "ingress_port" {
	description = "The port for HTTP traffic"
	type = number
        default = 8080
}

output "sg_id" {
	description = "The ID of the created security group"
	value = aws_security_group.security_group_server_1.id
}
output "aws_instance_pub_ip" {
	description = "The public IP of the created EC2 instance"
	value = aws_instance.server_1.public_ip
}
