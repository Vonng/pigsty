#################################
## SSH KEY (REPLACE THIS!!!!)
#################################
# ssh-keygen -t rsa -N '' -f ~/.ssh/pigsty-key

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "pigsty_key" {
  key_name   = "pigsty-key"
  public_key = file("~/.ssh/pigsty-key.pub")
}

################################
# SECURITY GROUP
################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "pigsty_sg" {
  name        = "pigsty-sg"
  description = "Pigsty Security Group"
  vpc_id      = aws_vpc.pigsty_vpc.id
  tags = {
    Name        = "pigsty-sg"
    VPC         = aws_vpc.pigsty_vpc.id
    Project     = "pigsty"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

################################
# SECURITY RULE
################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule

resource "aws_security_group_rule" "public_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Public Access Out"
  security_group_id = aws_security_group.pigsty_sg.id
}

resource "aws_security_group_rule" "public_in" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  # TODO: LIMIT ACCESS WITH YOUR OWN CIDR BLOCKS!!!!
  # OTHERWISE ALL SERVICES WILL BE OPENED TO THE WORLD!!!!
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Public Access In"
  security_group_id = aws_security_group.pigsty_sg.id
}


## allow ssh public in
#resource "aws_security_group_rule" "public_in_ssh" {
# type              = "ingress"
# from_port         = 22
# to_port           = 22
# protocol          = "tcp"
# cidr_blocks       = ["0.0.0.0/0"]
# security_group_id = aws_security_group.pigsty_sg.id
#}
#
## allow grafana direct port access
#resource "aws_security_group_rule" "public_in_https" {
# type              = "ingress"
# from_port         = 3000
# to_port           = 3000
# protocol          = "tcp"
# cidr_blocks       = ["0.0.0.0/0"]
# security_group_id = aws_security_group.pigsty_sg.id
#}
#
## allow http in (not available in mainland china)
#resource "aws_security_group_rule" "public_in_http" {
#  type              = "ingress"
#  from_port         = 80
#  to_port           = 80
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.pigsty_sg.id
#}