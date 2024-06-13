resource "aws_subnet" "access" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.network_vars.access_subnet.cidr
  map_public_ip_on_launch = true
  availability_zone = var.network_vars.access_subnet.availability_zone

  tags = {
    Name = "access_subnet"
  }
}

resource "aws_route_table" "access_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "access_route_table"
  }
}

resource "aws_route_table_association" "access" {
  subnet_id      = aws_subnet.access.id
  route_table_id = aws_route_table.access_route_table.id
}

resource "aws_vpc_endpoint_route_table_association" "access_to_s3" {
  route_table_id  = aws_route_table.access_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
