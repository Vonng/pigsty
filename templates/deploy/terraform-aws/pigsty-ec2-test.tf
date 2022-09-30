################################
# INSTANCES (OLTP)
################################

# c5d.metal 96C x 3.6GHz, 192G
#resource "aws_instance" "pg-oltp-1" {
#  ami                         = "ami-01cb2ecea35798f3f"
#  instance_type               = "c5d.metal"
#  key_name                    = "pigsty-key"
#  private_ip                  = "10.10.10.11"
#  associate_public_ip_address = true
#  vpc_security_group_ids      = [aws_security_group.pigsty_sg.id]
#  subnet_id                   = aws_subnet.pigsty_subnet.id
#  user_data                   = file("userdata.tpl")
#  root_block_device {
#    volume_size = 30
#  }
#  tags = {
#    Name        = "PostgreSQL OLTP Node"
#    VPC         = aws_vpc.pigsty_vpc.id
#    Project     = "pigsty"
#    Environment = "dev"
#    ManagedBy   = "terraform"
#    cls         = "pg-oltp"
#    ins         = "pg-oltp-1"
#  }
#}
#
#output "oltp_ip" {
#  value = aws_instance.pg-oltp-1.public_ip
#}

# mount nvme ssd before use
#mkdir /data /data1 /data2 /data3
#mkfs -t ext4 /dev/nvme0n1; mkfs -t ext4 /dev/nvme1n1; mkfs -t ext4 /dev/nvme3n1; mkfs -t ext4 /dev/nvme4n1;
#mount -t ext4 /dev/nvme0n1 /data ; mount -t ext4 /dev/nvme1n1 /data1; mount -t ext4 /dev/nvme3n1 /data2; mount -t ext4 /dev/nvme4n1 /data3;

################################
# INSTANCES (OLTP)
################################
#resource "aws_instance" "pg-olap-1" {
#  ami                         = "ami-01cb2ecea35798f3f"
#  instance_type               = "c5d.metal"
#  key_name                    = "pigsty-key"
#  private_ip                  = "10.10.10.12"
#  associate_public_ip_address = true
#  vpc_security_group_ids      = [aws_security_group.pigsty_sg.id]
#  subnet_id                   = aws_subnet.pigsty_subnet.id
#  user_data                   = file("userdata.tpl")
#  root_block_device {
#    volume_size = 30
#  }
#  tags = {
#    Name        = "PostgreSQL OLAP Node"
#    VPC         = aws_vpc.pigsty_vpc.id
#    Project     = "pigsty"
#    Environment = "dev"
#    ManagedBy   = "terraform"
#    cls         = "pg-olap"
#    ins         = "pg-olap-1"
#  }
#}
#
#output "olap_ip" {
#  value = aws_instance.pg-olap-1.public_ip
#}