# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "pigsty_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "pigsty-vpc"
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet
resource "aws_subnet" "pigsty_subnet" {
  vpc_id                  = aws_vpc.pigsty_vpc.id
  cidr_block              = "10.10.10.0/24"
  availability_zone       = "cn-northwest-1a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "pigsty-subnet"
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "pigsty_igw" {
  vpc_id = aws_vpc.pigsty_vpc.id
  tags = {
    Name        = "pigsty-vpc"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "pigsty_rt" {
  vpc_id = aws_vpc.pigsty_vpc.id
  tags = {
    Name        = "pigsty-route"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.pigsty_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pigsty_igw.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "pigsty_assoc" {
  subnet_id      = aws_subnet.pigsty_subnet.id
  route_table_id = aws_route_table.pigsty_rt.id
}