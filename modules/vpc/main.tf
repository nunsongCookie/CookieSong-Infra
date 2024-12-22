# vpc
resource "aws_vpc" "song-vpc-an2" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "song-vpc-an2"
  }
}

# 2 public subnet
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_names)
  vpc_id            = aws_vpc.song-vpc-an2.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zone_list[count.index]

  tags = {
    "Name" = "${var.public_subnet_names[count.index]}"
  }
}

# 2 private web subnet
resource "aws_subnet" "private_web_subnets" {
  count             = length(var.private_subnet_web_names)
  vpc_id            = aws_vpc.song-vpc-an2.id
  cidr_block        = var.private_subnet_web_cidr[count.index]
  availability_zone = var.availability_zone_list[count.index]

  tags = {
    "Name" = "${var.private_subnet_web_names[count.index]}"
  }
}

# 2 private was subnet
resource "aws_subnet" "private_was_subnets" {
  count             = length(var.private_subnet_was_names)
  vpc_id            = aws_vpc.song-vpc-an2.id
  cidr_block        = var.private_subnet_was_cidr[count.index]
  availability_zone = var.availability_zone_list[count.index]

  tags = {
    "Name" = "${var.private_subnet_was_names[count.index]}"
  }
}

# 2 private rds subnet
resource "aws_subnet" "private_rds_subnets" {
  count             = length(var.private_subnet_rds_names)
  vpc_id            = aws_vpc.song-vpc-an2.id
  cidr_block        = var.private_subnet_rds_cidr[count.index]
  availability_zone = var.availability_zone_list[count.index]

  tags = {
    "Name" = "${var.private_subnet_rds_names[count.index]}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.song-vpc-an2.id
  tags = {
    "Name" = "song-igw-an2"
  }
}

# Elastic IP
resource "aws_eip" "nat-eip" {
  domain = "vpc"
}
# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    "Name" = "song-nat-an2-az1"
  }
}

# public Route table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.song-vpc-an2.id

  tags = {
    "Name" = "song-rt-pub-an2"
  }
}
resource "aws_route" "pubRoute" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.pub-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

# private Route table
resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.song-vpc-an2.id

  tags = {
    "Name" = "song-rt-pri-an2"
  }
}
resource "aws_route" "priRoute" {
  gateway_id             = aws_nat_gateway.natgw.id
  route_table_id         = aws_route_table.pri-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route table - subnet association
# public
resource "aws_route_table_association" "pub-asso" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.pub-rt.id
}

#private
resource "aws_route_table_association" "pri-web-asso" {
  count          = 2
  subnet_id      = aws_subnet.private_web_subnets[count.index].id
  route_table_id = aws_route_table.pri-rt.id
}

resource "aws_route_table_association" "pri-was-asso" {
  count          = 2
  subnet_id      = aws_subnet.private_was_subnets[count.index].id
  route_table_id = aws_route_table.pri-rt.id
}

resource "aws_route_table_association" "pri-rds-asso" {
  count          = 2
  subnet_id      = aws_subnet.private_rds_subnets[count.index].id
  route_table_id = aws_route_table.pri-rt.id
}
