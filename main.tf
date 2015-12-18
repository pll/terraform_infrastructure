provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.region}"
}

module "vpc" {
    source             = "git::ssh://git@<module_server>/modules/vpc.git"
    env                = "${var.environment}"
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key     = "${var.aws_secret_key}"
    aws_region         = "us-east-1"
    account            = "${var.account_name}"
    availability_zones = "${var.availability_zones}"

    vpc_cidr           = "${var.vpc_cidr}"
    pub_count          = "${var.pub_count}"
    pub_offset         = "${var.pub_offset}"

    pri_count          = "${var.pri_count}"
    pri_offset         = "${var.pri_offset}"

    datacenter         = "${var.datacenter}"
    datacenter_cidr    = "${var.datacenter_cidr}"
}

module "dns" {
    source  = "git::ssh://git@<module_server>/modules/route53.git"
    vpc_id              = "${module.vpc.vpc_id}"
    account             = "${var.account_name}"
    env                 = "${var.environment}"
    private_dns_zone    = "${var.priv_dns_zone}"
    datacenter		= "${var.datacenter}"
    datacenter_dns_1    = "${var.datacenter_dns_1}"
    datacenter_dns_2    = "${var.datacenter_dns_2}"
    datacenter_dns_zone = "<datacenter dns zone>"
}

module "nat" {
    source             = "git::ssh://git@<module_server>/modules/nat.git"
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key     = "${var.aws_secret_key}"
    aws_key_name       = "${var.aws_key_name}"
    aws_region         = "${var.aws_region}"
    account            = "${var.account_name}"
    vpc_id             = "${module.vpc.vpc_id}"
    account            = "${var.account_name}"
    env                = "${var.environment}"

    pri_subnet_ids     = "${module.vpc.private_ids}"
    pri_subnet_cidrs   = "${module.vpc.private_cidrs}"

    pub_subnet_ids     = "${module.vpc.public_ids}"
    pub_subnet_cidrs   = "${module.vpc.public_cidrs}"

    availability_zones = "${var.availability_zones}"
    number_of_nats     = "${var.number_of_nats}"
    nat_ami            = "${var.aws_nat_ami}"
    nat_instantype  = "${var.aws_nat_instantype}"
    nat_sg             = "${module.vpc.nat_sg}"
}

module "route_tables" {
    source             = "git::ssh://git@<module_server>/modules/route_tables.git"
    aws_access_key     = "${var.aws_access_key}"
    aws_secret_key     = "${var.aws_secret_key}"
    aws_key_name       = "${var.aws_key_name}"
    availability_zones = "${var.availability_zones}"
    account            = "${var.account_name}"
    env                = "${var.environment}"
    datacenter_cidr    = "${var.datacenter_cidr}"
    vpc_id             = "${module.vpc.vpc_id}"
    vgw_id             = "${module.vpc.vpc_vgw_id}"
    igw_id             = "${module.vpc.igw_id}"

    pub_count          = "${var.pub_count}"
    pri_count          = "${var.pri_count}"

    pri_subnet_ids     = "${module.vpc.private_ids}"
    pri_subnet_cidrs   = "${module.vpc.private_cidrs}"

    pub_subnet_ids     = "${module.vpc.public_ids}"
    pub_subnet_cidrs   = "${module.vpc.public_cidrs}"

    number_of_nats     = "${var.number_of_nats}"

    nat_eni_ids        = "${module.nat.nat_eni_ids}"
}

module "s3_endpoints" {
    source           = "git::ssh://git@<module_server>/modules/s3.git"
    aws_access_key   = "${var.aws_access_key}"
    aws_secret_key   = "${var.aws_secret_key}"
    aws_key_name     = "${var.aws_key_name}"
    vpc_id           = "${module.vpc.vpc_id}"
    pri_rtbl_id_list = "${module.route_tables.private_route_table_ids}"
    pub_rtbl_id_list = "${module.route_tables.public_route_table_id}"
}

#######
# IAM #
#######
# we need a general IAM role policy for puppet to be able to query api and get
# tags
resource "template_file" "iam_role_policy" {
    filename = "templates/iam_role_policy.tpl"
}

resource "aws_iam_role_policy" "ec2_readonly" {
    name   = "${var.environment}_puppet_role_policy"
    role   = "${aws_iam_role.role.id}"
    policy = "${template_file.iam_role_policy.rendered}"
}


resource "aws_iam_role" "role" {
    name = "${var.environment}_puppet_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instanprofile" "instanprofile" {
    name  = "${var.environment}_puppet_instanprofile"
    roles = ["${aws_iam_role.role.id}"]
}



######################################################################
# Private Subnet Tester Instances
#
# Uncomment this to spin up a basic instance in each of the private
# subnets for testing purposes.
##
# resource "aws_instance" "subnet-tester" {
#     count         = "${var.pri_count}"
#     ami           = "${var.aws_nat_ami}"
#     key_name      = "${var.aws_key_name}"
#     subnet_id     = "${element(split(",",module.vpc.private_ids), count.index)}"
#     instantype = "${var.aws_nat_instantype}"
#     vpc_security_group_ids = [ "${module.vpc.nat_sg}" ]
#     tags              {
#                         "Name"    = "${var.environment}-nat-tester-subnet-${count.index}"
#                         "owner"   = "${var.owner}"
#                         "email"   = "${var.email}"
#                         "group"   = "${var.group}"
#                         "env"     = "${var.environment}"
#                       }
# }
