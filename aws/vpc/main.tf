provider "aws" {
  region = "eu-central-1"
}


resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

}

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  #   route {
  #     cidr_block = "10.1.0.0/16"
  #   }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.1.1.0/24"
  tags = {
    "Name" = "Public Subnet 1"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "Public Subnet 2"
  }
}



resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.1.3.0/24"
  tags = {
    "Name" = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "Private Subnet 2"
  }
}

resource "aws_security_group" "test" {
  name        = "test"
  description = "test"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_eip" "one" {
  vpc        = true
  instance   = aws_instance.web.id
  depends_on = [aws_internet_gateway.gw, aws_instance.web]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

resource "aws_instance" "web" {
  security_groups = [aws_security_group.test.id]
  ami             = "ami-0a1ee2fb28fe05df3"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_1.id
  tags = {
    Name = "web"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
echo "<h1>Hello World</h1>" > /var/www/html/index.html
EOF
}
