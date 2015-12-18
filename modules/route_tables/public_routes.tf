######################################################################
## Route table for public subnets
###
resource "aws_route_table" "public-route-table" {
   vpc_id = "${var.vpc_id}"
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${var.igw_id}"
   }
   tags   = {
              "Name"  = "${var.env} Public Route Table"
              "owner" = "${var.owner}"
              "email" = "${var.email}"
              "group" = "${var.group}"
              "env"   = "${var.env}"
             }
}
output "public_route_table_id" {
   value = "${aws_route_table.public-route-table.id}"
}

resource "aws_route_table_association" "public-rtb" {
   count          = "${var.pub_count}"
   subnet_id      = "${element(split(",",var.pub_subnet_ids), count.index)}"
   route_table_id = "${aws_route_table.public-route-table.id}"
}

output "pub_rtbl_assoc_ids" {
   value = "${ join(",", aws_route_table_association.public-rtb.*.id) }"
}


