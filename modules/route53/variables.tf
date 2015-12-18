######################################################################
# VPC config settings
###
variable "owner"          {   default = "<Owner Name>"  }
variable "email"          {   default = "<Group Email>" }
variable "group"          {   default = "<Group Tag>"   }
variable "env"            {}
variable "account"        {}

# DNS
variable "private_dns_zone" {}

# VPC info
variable "vpc_id"         {}
