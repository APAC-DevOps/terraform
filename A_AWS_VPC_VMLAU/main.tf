provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

// create VPC
resource "aws_vpc" "jhw_vpc" {
  cidr_block = "10.65.65.0/24"
  instance_tenancy = "default"

  tags {
    Name = "JHW_VPC"
  }
}

// create Internet Gateway
resource "aws_internet_gateway" "igw_jhw_vpc" {
    vpc_id = "${aws_vpc.jhw_vpc.id}"

    tags {
      Name = "IGW_For_JHW_VPC"
    }
}
// define vpc endpoint connection to s3
resource "aws_vpc_endpoint" "jhw_vpc_to_s3" {
    vpc_id = "${aws_vpc.jhw_vpc.id}"
    service_name = "com.amazonaws.ap-southeast-2.s3"
    route_table_ids = [ "${aws_route_table.jhw_public_routing_table_zone_a.id}", "${aws_route_table.jhw_public_routing_table_zone_b.id}"]
}

//define eip for aws nat Gateway
resource "aws_eip" "nat_public_subnet_zone_a" {
    depends_on = [ "aws_internet_gateway.igw_jhw_vpc"]
}

resource "aws_eip" "nat_public_subnet_zone_b" {
    depends_on = [ "aws_internet_gateway.igw_jhw_vpc"]
}

//define subnets in AWS VPC
resource "aws_subnet" "jhw_vpc_public_subnet_zone_a" {
  vpc_id = "${aws_vpc.jhw_vpc.id}"
  cidr_block = "10.65.65.0/27"
  availability_zone = "ap-southeast-2a"

  tags {
    Name = "JHW_VPC_PUBLIC_SUBNET_ZONE_A"
  }
}

resource "aws_subnet" "jhw_vpc_private_subnet_zone_a" {
  vpc_id = "${aws_vpc.jhw_vpc.id}"
  cidr_block = "10.65.65.64/28"
  availability_zone = "ap-southeast-2a"

  tags {
    Name = "JHW_VPC_PRIVATE_SUBNET_ZONE_A"
  }
}

resource "aws_subnet" "jhw_vpc_public_subnet_zone_b" {
  vpc_id = "${aws_vpc.jhw_vpc.id}"
  cidr_block = "10.65.65.128/27"
  availability_zone = "ap-southeast-2b"

  tags {
    Name = "JHW_VPC_PUBLIC_SUBNET_ZONE_B"
  }
}

resource "aws_subnet" "jhw_vpc_private_subnet_zone_b" {
  vpc_id = "${aws_vpc.jhw_vpc.id}"
  cidr_block = "10.65.65.192/28"
  availability_zone = "ap-southeast-2b"

  tags {
    Name = "JHW_VPC_PRIVATE_SUBNET_ZONE_B"
  }
}

//define aws nat Gateway
resource "aws_nat_gateway" "nat_public_subnet_zone_a" {
  allocation_id = "${aws_eip.nat_public_subnet_zone_a.id}"
  subnet_id = "${aws_subnet.jhw_vpc_public_subnet_zone_a.id}"
}

resource "aws_nat_gateway" "nat_public_subnet_zone_b" {
  allocation_id = "${aws_eip.nat_public_subnet_zone_b.id}"
  subnet_id = "${aws_subnet.jhw_vpc_public_subnet_zone_b.id}"
}

//define routing for subnets in zone a
resource "aws_route_table" "jhw_public_routing_table_zone_a" {
      vpc_id = "${aws_vpc.jhw_vpc.id}"

      tags {
        Name = "JHW_VPC_PUBLIC_ROUTING_TABLE_ZONE_A"
      }
}

resource "aws_route" "jhw_public_route_zone_a" {
    route_table_id = "${aws_route_table.jhw_public_routing_table_zone_a.id}"
    destination_cidr_block = "0.0.0.0/0"
    depends_on = [ "aws_route_table.jhw_public_routing_table_zone_a"]
    gateway_id = "${aws_internet_gateway.igw_jhw_vpc.id}"
}

resource "aws_route_table_association" "jhw_public_routing_table_association_zone_a" {
    subnet_id = "${aws_subnet.jhw_vpc_public_subnet_zone_a.id}"
    route_table_id = "${aws_route_table.jhw_public_routing_table_zone_a.id}"
}

resource "aws_route_table" "jhw_private_routing_table_zone_a" {
      vpc_id = "${aws_vpc.jhw_vpc.id}"

      tags {
        Name = "JHW_VPC_PRIVATE_ROUTING_TABLE_ZONE_A"
      }
}

resource "aws_route_table_association" "jhw_private_routing_table_association_zone_a" {
    subnet_id = "${aws_subnet.jhw_vpc_private_subnet_zone_a.id}"
    route_table_id = "${aws_route_table.jhw_private_routing_table_zone_a.id}"
}

//define routing for subnets in zone b
resource "aws_route_table" "jhw_public_routing_table_zone_b" {
      vpc_id = "${aws_vpc.jhw_vpc.id}"

      tags {
        Name = "JHW_VPC_PUBLIC_ROUTING_TABLE_ZONE_B"
      }
}

resource "aws_route" "jhw_public_route_zone_b" {
    route_table_id = "${aws_route_table.jhw_public_routing_table_zone_b.id}"
    destination_cidr_block = "0.0.0.0/0"
    depends_on = [ "aws_route_table.jhw_public_routing_table_zone_b"]
    gateway_id = "${aws_internet_gateway.igw_jhw_vpc.id}"
}

resource "aws_route_table_association" "jhw_public_routing_table_association_zone_b" {
    subnet_id = "${aws_subnet.jhw_vpc_public_subnet_zone_b.id}"
    route_table_id = "${aws_route_table.jhw_public_routing_table_zone_b.id}"
}

resource "aws_route_table" "jhw_private_routing_table_zone_b" {
      vpc_id = "${aws_vpc.jhw_vpc.id}"

      tags {
        Name = "JHW_VPC_PRIVATE_ROUTING_TABLE_ZONE_B"
      }
}

resource "aws_route_table_association" "jhw_private_routing_table_association_zone_b" {
    subnet_id = "${aws_subnet.jhw_vpc_private_subnet_zone_b.id}"
    route_table_id = "${aws_route_table.jhw_private_routing_table_zone_b.id}"
}
//define security groups
resource "aws_security_group" "sg_for_public_routing_table_zone_a" {
    name = "sg_for_public_routing_table_zone_a"
    description = "Security Group For Public Routing Table Zone A"
    vpc_id = "${aws_vpc.jhw_vpc.id}"
}

resource "aws_security_group" "sg_for_public_routing_table_zone_b" {
    name = "sg_for_public_routing_table_zone_b"
    description = "Security Group For Public Routing Table Zone B"
    vpc_id = "${aws_vpc.jhw_vpc.id}"
}

// define security group rules for zone a
resource "aws_security_group_rule" "sgr_ingress_for_public_routing_table_zone_a" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg_for_public_routing_table_zone_a.id}"
}

resource "aws_security_group_rule" "sgr_egress_for_public_routing_table_zone_a" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg_for_public_routing_table_zone_a.id}"
}

// define security group rules for zone b
resource "aws_security_group_rule" "sgr_ingress_for_public_routing_table_zone_b" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg_for_public_routing_table_zone_b.id}"
}

resource "aws_security_group_rule" "sgr_egress_for_public_routing_table_zone_b" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg_for_public_routing_table_zone_b.id}"
}

//Outputs
output "sg_for_public_routing_table_zone_a" {
  value = "${aws_security_group.sg_for_public_routing_table_zone_a.id}"
}

output "sg_for_public_routing_table_zone_b" {
  value = "${aws_security_group.sg_for_public_routing_table_zone_b.id}"
}

output "jhw_vpc" {
  value = "${aws_vpc.jhw_vpc.id}"
}

output "jhw_vpc_public_subnet_zone_a" {
  value = "${aws_subnet.jhw_vpc_public_subnet_zone_a.id}"
}

output "jhw_vpc_public_subnet_zone_b" {
  value = "${aws_subnet.jhw_vpc_public_subnet_zone_b.id}"
}

output "jhw_vpc_private_subnet_zone_a" {
  value = "${aws_subnet.jhw_vpc_private_subnet_zone_a.id}"
}

output "jhw_vpc_private_subnet_zone_b" {
  value = "${aws_subnet.jhw_vpc_private_subnet_zone_b.id}"
}
