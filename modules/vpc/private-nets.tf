######################################################################
## Private Subnets
###
resource "aws_subnet" "priv" { 
   vpc_id                  = "${aws_vpc.vpc.id}"
   count                   = "${var.pri_count}"
   cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, count.index + var.pri_offset)}"  
   availability_zone       = "${element(split(",", var.availability_zones), count.index)}"
   map_public_ip_on_launch = false
   tags                    = {
                               "Name"        = "${var.env}-priv-${count.index}"
                               "owner"       = "${var.owner}"
                               "email"       = "${var.email}"
                               "group"       = "${var.group}"
                               "env"         = "${var.env}"
                               "NetworkType" = "private"
                             }
}


######################################################################
# Output vars
##
output "private_ids" {
 value = "${join(",", aws_subnet.priv.*.id) }"
}

output "private_cidrs" {
 value = "${join(",", aws_subnet.priv.*.cidr_block)}"
}
