######################################################################
# All Variables must be set here, in terraform.tfvars, or on the
# command line.
###

######################################################################
# AWS Variables
###
variable "aws_key_name"       {   default = "<SSH Keypair>"}
variable "aws_region"         {   default = "<Default Region>"    }

######################################################################
# VPC config settings
###
variable "owner"          {   default = "<Owner Name>"     }
variable "email"          {   default = "<Group Email>"    }
variable "group"          {   default = "<Group Tag>"      }
variable "env"            { }
variable "account"        { }

######################################################################
# Network config settings
##
variable "vpc_id"           { }
variable "pri_rtbl_id_list" { }
variable "pub_rtbl_id_list" { }
