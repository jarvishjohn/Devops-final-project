resource "aws_vpc" "vpc" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "devprojectvpc"
  }
}
resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "11.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "devprojectsubnet-1"
  }
}
resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "11.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "devprojectsubnet-2"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "devprojectigw"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "devprojectrt"
  }
}
resource "aws_route_table_association" "rta-1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rta-2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_instance" "ec2-1" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public-1.id
  vpc_security_group_ids = [ aws_security_group.sg-1.id ]
  associate_public_ip_address = true
  user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install -y docker.io
  EOF

  tags = {
    Name = "Ec2-az1"
  }
}
resource "aws_instance" "ec2-2" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public-2.id
  vpc_security_group_ids = [ aws_security_group.sg-1.id ]
  associate_public_ip_address = true

  tags = {
    Name = "Ec2-az2"
  }
}
resource "aws_security_group" "sg-1" {
  name        = "Alltraffic"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "allow_all"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg-1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg-1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}
output "ec2-1-public-ip" {
    value = aws_intance.ec2-1.public_ip
  
}





