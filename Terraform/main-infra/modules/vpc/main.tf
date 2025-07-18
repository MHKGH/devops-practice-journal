resource "aws_vpc" "main" {
    cidr_block = var.vpc_main_cidr_block
    tags = merge(
    var.tags,
    {
      Name = "${var.env}-practice-VPC"
    }
  )
}


resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_block
    availability_zone = "ap-south-1a"

    tags = merge(
    var.tags,
    {
      Name = "${var.env}-Public-Subnet"
    }
  )
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "Practice-IGW"
    }
  
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public-RT"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
  
}