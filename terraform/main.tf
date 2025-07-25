terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}

# Create a VPC
resource "aws_vpc" "node-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "node-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.node-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  

  tags = {
    Name = "subnet1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.node-vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.node-vpc.id

  route {
    cidr_block = "0.0.0.0/0"                  
    gateway_id = aws_internet_gateway.gw.id 
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.node-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh-http"
  }
}

resource "aws_instance" "my_instance" {
    ami = "ami-00f850c0feb18986f"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]

    key_name = "sshkey"
    
    user_data = file("${path.module}/user_data.sh")


    associate_public_ip_address = true


    tags = {
        Name = "node server"
    }
}