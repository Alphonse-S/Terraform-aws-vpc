resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

#create public subnets
resource "aws_subnet" "prod-pub-sub-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "prod-pub-sub-1"
  }
}
resource "aws_subnet" "prod-pub-sub-2" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-pub-sub-2"
  }
}
#create private subnets

resource "aws_subnet" "prod-priv-sub-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "prod-priv-sub-1"
  }
  }
resource "aws_subnet" "prod-priv-sub-2" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "prod-priv-sub-2"
  }
}
#create route tables
resource "aws_route_table" "prod-pub-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route = []

  tags = {
    Name = "prod-pub-route-table"
  }
}

resource "aws_route_table" "prod-priv-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route = []

  tags = {
    Name = "prod-priv-route-table"
  }
}
#associate route table

resource "aws_route_table_association" "public-route-1" {
  subnet_id      = aws_subnet.prod-pub-sub-1.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}
resource "aws_route_table_association" "public-route-2" {
  subnet_id      = aws_subnet.prod-pub-sub-2.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}
resource "aws_route_table_association" "private-route-1" {
  subnet_id      = aws_subnet.prod-priv-sub-1.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}
resource "aws_route_table_association" "private-route-2" {
  subnet_id      = aws_subnet.prod-priv-sub-2.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}
#create internet gateway
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

resource "aws_route" "public-internet-route" {
  route_table_id            = aws_route_table.prod-pub-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id   = aws_internet_gateway.prod-igw.id
}

#EIP for nat gateway
resource "aws_eip" "nat_eip" {

  depends_on = [aws_internet_gateway.prod-igw]

  tags = {

    name = "Nat gateway EIP"

  }




}




#create nat gateway 
resource "aws_nat_gateway" "Prod-Nat-Gateway" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id     = aws_subnet.prod-pub-sub-1.id




  tags = {

    Name = "Prod-Nat-Gateway"

  }




}




#route table for Nat gateway 

resource "aws_route_table" "Nat-private" {

  vpc_id = aws_vpc.prod-vpc.id




  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.prod-igw.id

  }




  tags = {

    Name = "private-route-forNat"

  }

}