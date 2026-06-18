provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server_1" {
  ami = "ami-0f8a61b66d1accaee"
  instance_type = "t2.micro"
  tags = {
	Name = "server_1"
  }
}
