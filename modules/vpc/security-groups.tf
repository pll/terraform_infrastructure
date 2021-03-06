######################################################################
## Set up Security Group for Private subnets/NATs
###
resource "aws_security_group" "nat_sg" {
   name           = "${var.env}_nat_sg"
   description    = "Allow services from the private subnet through NAT"
   vpc_id         = "${aws_vpc.vpc.id}"

   # Allow ICMP to private subnets
   ingress {
       from_port   = -1
       to_port     = -1
       protocol    = "icmp"
       self        = true
       cidr_blocks = [ "${aws_subnet.priv.*.cidr_block}" ]
   }

   ######################################################################
   # Inbound Traffic
   ##   
   # Allow ALL traffic from this SG
   ingress {
       from_port = <subnet offset to start at>
       to_port   = <subnet offset to start at>
       protocol  = "-1"
       self      = true
   }

   # Allow SSH from anywhere
   ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   # Allow all port 80 traffic inbound to private subnets
   ingress {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       cidr_blocks = [ "${aws_subnet.priv.*.cidr_block}" ]
   }		     

   # Allow all port 443 traffic inbound to private subnets
   ingress {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = [ "${aws_subnet.priv.*.cidr_block}" ]
   }		     

   ######################################################################
   # Outbound Traffic
   ##

   # Allow all traffic out from this subnet to anywhere
   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags           = {
                      "Name"        = "${var.env} Private->NAT SG"
                      "owner"       = "${var.owner}"
                      "email"       = "${var.email}"
                      "group"       = "${var.group}"
                      "env"         = "${var.env}"
                      "NetworkType" = "private"
                    }
}

output "nat_sg" {
   value = "${aws_security_group.nat_sg.id}"
}

######################################################################
## Set up Security Group for private subs<->datacenter access
###
resource "aws_security_group" "datacenter_sg" {
   name           = "${var.env}_${var.datacenter}_sg"
   description    = "Allow services from the private subnet to DC"
   vpc_id         = "${aws_vpc.vpc.id}"
   ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [
                     "0.0.0.0/0", 
                     "${var.datacenter_cidr}"
		    ]
   }
   ingress {
       from_port = 0
       to_port = 0
       protocol = "-1"
       self = true
   }

   ingress {
       from_port = 0
       to_port = 0
       protocol = "-1"
   }

   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags           = {
                      "Name"        = "${var.env} Private->${var.datacenter} SG"
                      "owner"       = "${var.owner}"
                      "email"       = "${var.email}"
                      "group"       = "${var.group}"
                      "env"         = "${var.env}"
                      "NetworkType" = "private"
                    }
}

output "datacenter_sg" {
   value = "${aws_security_group.datacenter_sg.id}"
}
