#################################
# INSTANCES (Pigsty Meta)
#################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "pigsty-meta" {
  ami                         = "ami-01cb2ecea35798f3f"
  instance_type               = "t2.micro"
  key_name                    = "pigsty-key"
  private_ip                  = "10.10.10.10"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pigsty_sg.id]
  subnet_id                   = aws_subnet.pigsty_subnet.id
  user_data                   = file("userdata.tpl")

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name        = "Pigsty Meta Node"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
    cls         = "pg-meta"
    ins         = "pg-meta-1"
  }
}


#################################
# Elastic IP
#################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

resource "aws_eip" "pigsty-ip" {
  vpc = true
  instance                  = aws_instance.pigsty-meta.id
  associate_with_private_ip = "10.10.10.10"
  depends_on                = [aws_internet_gateway.pigsty_igw]
}

output "meta_ip" {
  value = aws_eip.pigsty-ip.public_ip
}


################################
# INSTANCES (TEST1)
################################
resource "aws_instance" "pigsty-test-1" {
  ami                         = "ami-01cb2ecea35798f3f"
  instance_type               = "t2.micro"
  key_name                    = "pigsty-key"
  private_ip                  = "10.10.10.11"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pigsty_sg.id]
  subnet_id                   = aws_subnet.pigsty_subnet.id
  user_data                   = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name        = "Pigsty Test Node 2"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
    cls         = "pg-test"
    ins         = "pg-test-2"
  }
}

################################
# INSTANCES (TEST2)
################################
resource "aws_instance" "pigsty-test-1" {
  ami                         = "ami-01cb2ecea35798f3f"
  instance_type               = "t2.micro"
  key_name                    = "pigsty-key"
  private_ip                  = "10.10.10.12"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pigsty_sg.id]
  subnet_id                   = aws_subnet.pigsty_subnet.id
  user_data                   = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name        = "Pigsty Test Node 2"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
    cls         = "pg-test"
    ins         = "pg-test-2"
  }
}


################################
# INSTANCES (TEST3)
################################
resource "aws_instance" "pigsty-test-1" {
  ami                         = "ami-01cb2ecea35798f3f"
  instance_type               = "t2.micro"
  key_name                    = "pigsty-key"
  private_ip                  = "10.10.10.13"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pigsty_sg.id]
  subnet_id                   = aws_subnet.pigsty_subnet.id
  user_data                   = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name        = "Pigsty Test Node 3"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
    cls         = "pg-test"
    ins         = "pg-test-3"
  }
}
