# creates the VPC

resource "aws_vpc" "demo-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Demo-VPC"
  }
}

# creates the public subnet

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-demo"
  }
}

# creates the internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo-igw"
  }
}

# creates the public route table and directs all traffic to internet gateway

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associates the public route table with the public subnet

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Creates the private subnet

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-demo"
  }
}

# Creates the elastic ip

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

# creates the NAT gateway

resource "aws_nat_gateway" "demo" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
}

# creates the private route table and directs all traffic to NAT gateway

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block     = var.all_traffic
    nat_gateway_id = aws_nat_gateway.demo.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associates the private route table with the private subnet

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# creates public ec2 instance in public subnet with http and ssh enabled

resource "aws_instance" "public" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.public_ec2.id
  ]
  associate_public_ip_address = true

  count = 1

  tags = {
    Name = "public-EC2"
  }
}

# security group rule for public ec2

resource "aws_security_group" "public_ec2" {
  name        = "public-ec2-sg"
  description = "public ec2 security group. (http/ssh)"
  vpc_id      = aws_vpc.demo-vpc.id

  # SSH
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_traffic] # for real-world deployment restrict to your own ip

  }

  # HTTP
  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_traffic]
  }

  # allow all outbound traffic
  egress {
    description = "enable all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_traffic]
  }
  tags = {
    Name = "public-ec2-sg"
  }

}

# creates ec2 instance in private subnet
resource "aws_instance" "private" {
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.private_ec2.id
  ]

  count = 1

  tags = {
    Name = "private-EC2"
  }
}

resource "aws_security_group" "private_ec2" {
  name        = "private-ec2-sg"
  description = "private ec2 security group"
  vpc_id      = aws_vpc.demo-vpc.id

  # Allow SSH from public ec2 security group
  ingress {
    description     = "ssh from public EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }
  # allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.all_traffic]
  }

  tags = {
    Name = "private-ec2-sg"
  }
}

