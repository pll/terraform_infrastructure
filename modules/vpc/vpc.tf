provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.aws_region}"
}

######################################################################
# Create the VPC and tag it
##
resource "aws_vpc" "vpc" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_support   = 1
    enable_dns_hostnames = 1
    tags                 = {
                             "Name"    = "${var.env}-${var.account}-vpc"
                             "owner"   = "${var.owner}"
                             "email"   = "${var.email}"
                             "group"   = "${var.group}"
                             "env"     = "${var.env}"
                           }
}

######################################################################
## Set up Internet Gateway
###
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags   = {
               "Name"  = "${var.env}-${var.account}-igw"
               "owner" = "${var.owner}"
               "email" = "${var.email}"
               "group" = "${var.group}"
               "env"   = "${var.env}"
             }
}
output "igw_id" {
   value = "${aws_internet_gateway.igw.id}"
}

######################################################################
## Set up VPN Gateway if necessary
###
resource "aws_vpn_gateway" "vgw" {
    count  = "${var.vpc_vgw_exists}"
    vpc_id = "${aws_vpc.vpc.id}"
    tags   = {
               "Name"    = "${var.env}-${var.datacenter}-vgw"
               "owner"   = "${var.owner}"
               "email"   = "${var.email}"
               "group"   = "${var.group}"
               "env"     = "${var.env}"
             }
}


output "vpc_name" {
    value = "${aws_vpc.vpc.tags.Name}"
}
output "vpc_id" {
   value = "${join(",", aws_vpc.vpc.*.id)}"
}
output "vpc_cidr" {
   value = "${var.vpc_cidr}"
}

output "vpc_vgw_name" {
   value = "${aws_vpn_gateway.vgw.tags.Name}"
}

output "vpc_vgw_id" {
   value = "${aws_vpn_gateway.vgw.id}"
}
