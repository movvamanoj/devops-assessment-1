# Set AWS provider configuration
provider "aws" {
  region = "us-east-1"  # Set your desired region
}

# Specify the required provider and version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1.0"
    }
  }
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    Name = "my-vpc-1"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Create a public subnet in the first availability zone
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Specify the desired availability zone

  tags = {
    Name = "public-subnet"
  }
}

# Create a private subnet in the first availability zone
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"  # Specify the desired availability zone

  tags = {
    Name = "private-subnet"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "public-route-table"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Attach the internet gateway to the public route table
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create a security group for the EC2 instances
resource "aws_security_group" "instance_sg" {
  name        = "ec2-instance-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all traffic
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH traffic
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow port 8080 traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH traffic
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow port 8080 traffic
  }
}

# Create EC2 instances in the public subnet
resource "aws_instance" "public_instance" {
  instance_type            = "t2.micro"  # Specify the desired instance type
  ami                      = "ami-0715c1897453cabd1"
  key_name                 = "manoj_virginia"
  subnet_id                = aws_subnet.public_subnet.id
  vpc_security_group_ids   = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
user_data = <<-EOF
	#!/bin/bash
	set -e
	curl -O https://raw.githubusercontent.com/movvamanoj/devops-assessment-1/main/app-install.sh
	sudo chmod +x app-install.sh
	./app-install.sh
EOF

  tags = {
    Name = "public-instance"
  }
}

# Create EC2 instance in the private subnet
resource "aws_instance" "private_instance" {
  instance_type            = "t2.micro"  # Specify the desired instance type
  ami                      = "ami-0715c1897453cabd1"
  key_name                 = "manoj_virginia"
  subnet_id                = aws_subnet.private_subnet.id
  vpc_security_group_ids   = [aws_security_group.instance_sg.id]

user_data = <<-EOF
	#!/bin/bash
	set -e
	curl -O https://raw.githubusercontent.com/movvamanoj/devops-assessment-1/main/app-install.sh
	sudo chmod +x app-install.sh
	./app-install.sh
EOF

  tags = {
    Name = "private-instance"
  }
}

# Create the classic Elastic Load Balancer 1 
resource "aws_elb" "classic_elb_1" {
  name               = "my-classic-elb-1"
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]  # Specify the desired subnets
  security_groups    = [aws_security_group.instance_sg.id]
  instances          = [aws_instance.public_instance.id, aws_instance.private_instance.id]
  cross_zone_load_balancing   = true

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:8080/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# Create the classic Elastic Load Balancer 2
resource "aws_elb" "classic_elb_2" {
 name               = "my-classic-elb-2"
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]  # Specify the desired subnets
  security_groups    = [aws_security_group.instance_sg.id]
  instances          = [aws_instance.public_instance.id, aws_instance.private_instance.id]
  cross_zone_load_balancing   = true
listener {
    instance_port     = 8888
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:8888/"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}
# Output the ELB DNS

output "elb_dns" {
  value = {
    my_load_balancer_Web_dns = aws_elb.classic_elb_1.dns_name
    my_load_balancer_DockerImage_dns = aws_elb.classic_elb_2.dns_name
  }
}

output "public_ip" {
  value = aws_instance.public_instance.public_ip
}
