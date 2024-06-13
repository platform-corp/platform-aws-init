
# Create a VPC endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Name = "s3-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type   = "Interface"

  subnet_ids          = [aws_subnet.secure.id]
  security_group_ids  = [aws_security_group.allow_kms.id]

  private_dns_enabled = true

  tags = {
    Name = "kms-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"

  subnet_ids          = [aws_subnet.secure.id]
  security_group_ids  = [aws_security_group.allow_secretsmanager.id]

  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-vpc-endpoint"
  }
}
