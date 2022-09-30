#################################
# INSTANCES (Pigsty Meta)
#################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "pigsty-meta" {
  ami                         = "ami-01cb2ecea35798f3f"
  instance_type               = "z1d.2xlarge"
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
    cls         = "pigsty-meta"
    ins         = "pigsty-meta-1"
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
