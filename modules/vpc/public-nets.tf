######################################################################
## Public Subnets
###
resource "aws_subnet" "public" { 
   vpc_id                  = "${aws_vpc.vpc.id}"
   count                   = "${var.pub_count}"
   cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, count.index + var.pub_offset)}"  

    availability_zone      = "${element(split(",", var.availability_zones), count.index)}"
   map_public_ip_on_launch = false
   tags                    = {
                               "Name"        = "${var.env}-public-${count.index}"
                               "owner"       = "${var.owner}"
                               "email"       = "${var.email}"
                               "group"       = "${var.group}"
                               "env"         = "${var.env}"
                               "NetworkType" = "public"
                             }
}

######################################################################
# Output vars
##
output "public_ids" {
 value = "${join(",",aws_subnet.public.*.id) }"
}

output "public_cidrs" {
 value = "${join(",",aws_subnet.public.*.cidr_block)}"
}

