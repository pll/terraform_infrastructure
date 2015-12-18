######################################################################
## Set up secondary route table for private subnets
###
resource "aws_route_table" "private-route-table" {
   vpc_id = "${var.vpc_id}"
   count  = "${var.number_of_nats}"
   route {
       # Default route via the NAT
       cidr_block           = "0.0.0.0/0"
       network_interface_id = "${element(split(",", var.nat_eni_ids), count.index)}"
   }
   route {
       # Datacenter traffic via the VGW
       cidr_block  = "${var.datacenter_cidr}"
       gateway_id  = "${var.vgw_id}"
   }
   # Make sure to propagate the VGW routes
   propagating_vgws = ["${var.vgw_id}"]
   tags   = {
              "Name"    = "${var.env} subnet-${count.index} Private Route Table "
              "owner"   = "${var.owner}"
              "email"   = "${var.email}"
              "group"   = "${var.group}"
              "env"     = "${var.env}"
            }
}

output "private_route_table_ids" {
   value = "${ join(",", aws_route_table.private-route-table.*.id) }"
}


######################################################################
## Associate private subnets with secondary route table
###
resource "aws_route_table_association" "priv-nat" {
   count          = "${var.pri_count}"
   subnet_id      = "${element(split(",",var.pri_subnet_ids), count.index)}"
   route_table_id = "${element(aws_route_table.private-route-table.*.id, count.index)}"
}

output "priv_nat_rtbl_assoc_ids" {
   value = "${ join(",", aws_route_table_association.priv-nat.*.id) }"
}
