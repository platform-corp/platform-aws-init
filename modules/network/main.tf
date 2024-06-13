variable "module_depends_on" {
  type    = any
  default = []
}

resource "aws_vpc" "main" {
  depends_on           = [ var.module_depends_on ]
  cidr_block           = var.network_vars.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.network_vars.vpc_name
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = var.domain_name
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.network_vars.vpc_name}-main-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.network_vars.vpc_name}-igw"
  }
}

output "network_config" {
  value = {
      main = {
        vpc_id = aws_vpc.main.id
        vpc_name = aws_vpc.main.tags.Name
        cidr_block = aws_vpc.main.cidr_block
        subnet = {
          access = {
            id = aws_subnet.access.id
            cidr_block = aws_subnet.access.cidr_block
            arn = aws_subnet.access.arn
            availability_zone = aws_subnet.access.availability_zone
          },
          secure = {
            id = aws_subnet.secure.id
            cidr_block = aws_subnet.secure.cidr_block
            arn = aws_subnet.secure.arn
            availability_zone = aws_subnet.secure.availability_zone
          }
        }
      }
    }
  }
