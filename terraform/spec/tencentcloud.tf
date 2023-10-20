terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "1.81.23"
    }
  }
}

# add your credentials here or pass them via env
# export TENCENTCLOUD_SECRET_ID="????????????????????"
# export TENCENTCLOUD_SECRET_KEY="????????????????????"
# e.g : ./tencentcloud-key.sh
provider "tencentcloud" {
  # secret_id = "????????????????????"
  # secret_key = "????????????????????"
  region = "${var.tencentcloud_region}"
}

variable "tencentcloud_region" {
  default = "ap-guangzhou"
  type    = string
}
variable "tencentcloud_zone" {
  default = "ap-guangzhou-7"
  type    = string
}
variable "tencentcloud_instance_password" {
  default = "PigstyDemo4"
  type    = string
}
variable "tencentcloud_vpc_cidr" {
  default = "10.10.10.0/24"
  type    = string
}
variable "tencentcloud_subnet_cidr" {
  default = "10.10.10.0/25"
  type    = string
}
variable "biz_prefix" {
  default = "demo"
  type    = string
}

# instance type 2c2g
data tencentcloud_instance_types "t2c2g" {
  cpu_core_count   = 2
  memory_size      = 2
  exclude_sold_out = true
  filter {
    name   = "instance-charge-type"
    values = ["POSTPAID_BY_HOUR"]
  }
  filter {
    name   = "zone"
    values = ["${var.tencentcloud_zone}"]
  }
}
# instance type 2c4g
data tencentcloud_instance_types "t2c4g" {
  cpu_core_count   = 2
  memory_size      = 4
  exclude_sold_out = true
  filter {
    name   = "instance-charge-type"
    values = ["POSTPAID_BY_HOUR"]
  }
  filter {
    name   = "zone"
    values = ["${var.tencentcloud_zone}"]
  }
}

# AVAILABLE PUBLIC IMAGES: https://console.cloud.tencent.com/cvm/image/detail?rid=8&id=img-no575grb
# EL7: CentOS 7.9 : img-l8og963d
# EL8: Rocky Linux 8.6 : img-no575grb
# EL9: Rocky Linux 9.2 : img-no59bf11
# U22: Ubuntu 22.04 :  img-487zeit5
# D12: Debian 12 : img-7ag0z2jt

data "tencentcloud_images" "rocky8" {
  image_type = ["PUBLIC_IMAGE"]
  os_name    = "Rocky Linux 8"
}
data "tencentcloud_images" "rocky9" {
  image_type = ["PUBLIC_IMAGE"]
  os_name    = "Rocky Linux 9"
}

# add vpc network
resource "tencentcloud_vpc" "vpc" {
  name       = "${var.biz_prefix}-pigsty-vpc"
  cidr_block = "${var.tencentcloud_vpc_cidr}"
}

# add route table for pigsty demo network
resource "tencentcloud_route_table" "route_table" {
  name   = "${var.biz_prefix}-pigsty-rtb"
  vpc_id = "${tencentcloud_vpc.vpc.id}"
}

# add subnet for pigsty demo network
resource "tencentcloud_subnet" "subnet" {
  name              = "${var.biz_prefix}-pigsty-subnet"
  cidr_block        = "${var.tencentcloud_subnet_cidr}"
  availability_zone = "${var.tencentcloud_zone}"
  vpc_id            = "${tencentcloud_vpc.vpc.id}"
  route_table_id    = "${tencentcloud_route_table.route_table.id}"
}

# add default security group and allow all tcp traffic
resource "tencentcloud_security_group" "security_group" {
  name = "${var.biz_prefix}-pigsty-sg"
}
resource "tencentcloud_security_group_lite_rule" "security_group_rule" {
  security_group_id = "${tencentcloud_security_group.security_group.id}"
  ingress           = [
    "ACCEPT#0.0.0.0/0#ALL#ALL"
  ]
  egress = [
    "ACCEPT#0.0.0.0/0#ALL#ALL"
  ]
}

# https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/instance
resource "tencentcloud_instance" "pg-meta-1" {
  instance_name              = "pg-meta-1"
  hostname                   = "pg-meta-1"
  instance_type              = data.tencentcloud_instance_types.t2c4g.instance_types.0.instance_type
  availability_zone          = "${var.tencentcloud_zone}"
  vpc_id                     = "${tencentcloud_vpc.vpc.id}"
  subnet_id                  = "${tencentcloud_subnet.subnet.id}"
  orderly_security_groups    = ["${tencentcloud_security_group.security_group.id}"]
  image_id                   = data.tencentcloud_images.rocky8.images.0.image_id
  password                   = "${var.tencentcloud_instance_password}"
  private_ip                 = "10.10.10.10"
  allocate_public_ip         = true # alloc a public IP
  internet_max_bandwidth_out = 40 # 40Mbps
}

resource "tencentcloud_instance" "pg-test-groups" {
  for_each = toset(["1", "2", "3"])

  instance_name           = "pg-test-${each.key}"
  hostname                = "pg-test-${each.key}"
  private_ip              = "10.10.10.1${each.key}"
  instance_type           = data.tencentcloud_instance_types.t2c2g.instance_types.0.instance_type
  availability_zone       = "${var.tencentcloud_zone}"
  vpc_id                  = "${tencentcloud_vpc.vpc.id}"
  subnet_id               = "${tencentcloud_subnet.subnet.id}"
  orderly_security_groups = ["${tencentcloud_security_group.security_group.id}"]
  image_id                = data.tencentcloud_images.rocky8.images.0.image_id
  password                = "${var.tencentcloud_instance_password}"
}

output "tencentcloud_admin_ip" {
  value = "${tencentcloud_instance.pg-meta-1.public_ip}"
}
