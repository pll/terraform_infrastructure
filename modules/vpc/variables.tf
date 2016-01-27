######################################################################
# All Variables must be set here, in terraform.tfvars, or on the
# command line.
###

######################################################################
# AWS Variables
###
variable "aws_access_key"     { }
variable "aws_secret_key"     { }
variable "aws_region"         { }
variable "availability_zones" { }


######################################################################
# VPC config settings
###
variable "owner"          { }
variable "email"          { }
variable "group"          { }
variable "env"            { }
variable "account"        { }

######################################################################
# Network config settings
##

# The CIDR notation of the network block to be used.
# e.g.: 10.1.2.0/16, 192.168.1.0/24, etc.
#
# Defaults below assume a /16 sliced into 16 /20s
variable "vpc_cidr"         {}


# Public
# pub_count  = number of public, internet facing subnets to create
# pub_offset = index into a list of possible network blocks which
#              exist in vpc_cidr
#
variable "pub_count"        { default = <Number of subnets>         }
variable "pub_offset"       { default = <subnet offset to start at> }

# Private
# pri_count  = number of private, non-internet facing subnets to create
# pri_offset = index into a list of possible network blocks which
#              exist in vpc_cidr
#
# Default is to create 3 private subnets (assumes /20s) begining at the
# bottom of the range.
variable "pri_count"        { default = <Number of subnets>         }
variable "pri_offset"       { default = <subnet offset to start at> }

variable "datacenter"       {}
variable "datacenter_cidr"  {}
variable "vpc_vgw_exists"   {
         description = "Do we create a VGW? Boolean: 0 = No, 1 = Yes"
         default = 0
}
