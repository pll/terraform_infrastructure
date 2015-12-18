######################################################################
# All Variables must be set here, in terraform.tfvars, or on the
# command line.
###

######################################################################
# AWS Variables
###
variable "aws_access_key"     {}
variable "aws_secret_key"     {}
variable "aws_key_name"       {   default = "<SSH Keypair>"}
variable "aws_region"         {   default = "<Default Region>"    }
variable "availability_zones" { }


######################################################################
# VPC config settings
###
variable "owner"              {   default = "<Owner Name>"     }
variable "email"              {   default = "<Group Email>"    }
variable "group"              {   default = "<Group Tag>"      }
variable "env"                {}
variable "account"            {}

######################################################################
# Network config settings
##
variable "vpc_cidr"           {}

# Public
variable "pub_count"          { default = <Number of subnets>         }
variable "pub_offset"         { default = <subnet offset to start at> }

# Private
variable "pri_count"          { default = <Number of subnets>         }
variable "pri_offset"         { default = <subnet offset to start at> }

variable "datacenter"         {}
variable "datacenter_cidr"    {}
