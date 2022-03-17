provider "aws"  {
      region = "ap-southeast-1"
      access_key =" "
      secret_key = " "
    
    }
  

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames="true"

  tags = {
      Name = "new_vpc"
  }
  }


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "public subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "private subnet"
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_eip" "ip" {
   
  vpc      = true
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.private.id

  tags = {
    Name = "NGW"
  }
}
  resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

tags = {
    Name = "custom"
}
  }

  resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW.id
  }

tags = {
    Name = "main"
}
  }

  resource "aws_route_table_association" "as_1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "as_2" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt2.id
}

  resource "aws_security_group" "sg" {
  name        = "first-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "first-sg"
  }
}
