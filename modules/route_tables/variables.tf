######################################################################
# All Variables must be set here, in terraform.tfvars, or on the
# command line.
###

######################################################################
# AWS Variables
###
variable "aws_access_key"  { }
variable "aws_secret_key"  { }
variable "aws_key_name"    { }
variable "availability_zones" { }

######################################################################
# VPC config settings
###
variable "owner"           { default = "<Owner Name>"  }
variable "email"           { default = "<Group Email>" }
variable "group"           { default = "<Group Tag>"   }
variable "env"             { }
variable "account"         { }

######################################################################
# Network config settings
##
variable "vpc_id"          { }
variable "vgw_id"          { }
variable "igw_id"          { }

variable "number_of_nats"  { }

variable "pub_count"       { }
variable "pri_count"       { }

variable "pri_subnet_ids"   { }
variable "pri_subnet_cidrs" { }

variable "pub_subnet_ids"   { }
variable "pub_subnet_cidrs" { }


variable "datacenter_cidr" { }
variable "nat_eni_ids"     { }
