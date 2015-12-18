resource "aws_route53_zone" "private_dns_zone" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.private_dns_zone}"
  tags   = {
            "Name"    = "${var.env}-${var.account}"
            "owner"   = "${var.owner}"
            "email"   = "${var.email}"
            "group"   = "${var.group}"
            "env"     = "${var.env}"
         }  
}

resource "aws_route53_record" "ns-record" {
    zone_id = "${aws_route53_zone.private_dns_zone.zone_id}"
    name    = "${var.private_dns_zone}"
    type    = "NS"
    ttl     = "30"
    records = [
        "${aws_route53_zone.private_dns_zone.name_servers.0}",
        "${aws_route53_zone.private_dns_zone.name_servers.1}",
        "${aws_route53_zone.private_dns_zone.name_servers.2}",
        "${aws_route53_zone.private_dns_zone.name_servers.3}"
    ]
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name         = "${var.private_dns_zone}"
    domain_name_servers = [
                           "AmazonProvidedDNS",
			   "8.8.8.8",
                          ]
    tags                = {
                           "Name"  = "${var.env}-${var.account}-dhcp"
                           "owner" = "${var.owner}"
                           "email" = "${var.email}"
                           "group" = "${var.group}"
                           "env"   = "${var.env}"
                           }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id          = "${var.vpc_id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

output "dns_domain_name" {
     value = "${aws_route53_zone.private_dns_zone.name}"
}

output "dns_domain_id" {
     value = "${aws_route53_zone.private_dns_zone.id}"
}

output "dhcp_options_id" {
     value  = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
