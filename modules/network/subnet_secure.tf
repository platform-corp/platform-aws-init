resource "aws_subnet" "secure" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.network_vars.secure_subnet.cidr
  availability_zone = var.network_vars.secure_subnet.availability_zone

  tags = {
    Name = "secure_subnet"
  }
}

resource "aws_route_table" "secure_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "secure_route_table"
  }
}

resource "aws_route_table_association" "secure" {
  subnet_id      = aws_subnet.secure.id
  route_table_id = aws_route_table.secure_route_table.id
}


resource "aws_vpc_endpoint_route_table_association" "secure_to_s3" {
  route_table_id  = aws_route_table.secure_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
