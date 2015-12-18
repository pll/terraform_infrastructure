output "vpc_id" {
      value = "${module.vpc.vpc_id}"
}
output "vpc_name" {
      value = "${module.vpc.vpc_name}"
}
output "vpc_cidr" {
      value = "${module.vpc.vpc_cidr}"
}

output "vpc_vgw_name" {
   value = "${module.vpc.vpc_vgw_name}"
}

output "vpc_vgw_id" {
   value = "${module.vpc.vpc_vgw_id}"
}


output "private_subnet_ids" {
   value = "${module.vpc.private_ids}"
}

output "private_subnet_cidrs" {
   value = "${module.vpc.private_cidrs}"
}

output "public_subnet_ids" {
   value = "${module.vpc.public_ids}"
}

output "public_subnet_cidrs" {
   value = "${module.vpc.public_cidrs}"
}

output "s3_endpoint_id" {
  value = "${module.s3_endpoints.s3_endpoint_ids}"
}

output "private_route_table_ids" {
   value = "${module.route_tables.private_route_table_ids}"
}

output "igw_id" {
   value = "${module.vpc.igw_id}"
}

output "public_route_table_id" {
   value = "${module.route_tables.public_route_table_id}"
}

output "public_route_table_assoc_ids" {
   value = "${module.route_tables.pub_rtbl_assoc_ids}"
}

output "nat_security_group" {
   value = "${module.vpc.nat_sg}"
}

######################################################################
# NAT Module Outputs
##
output "nat_eni_ids" {
   value = "${module.nat.nat_eni_ids}"
}

output "nat_eni_ips" {
   value = "${module.nat.nat_eni_ips}"
}

output "nat_eip_private_ips" {
  value = "${module.nat.nat_eip_private_ip}"
}
output "nat_eip_public_ips" {
  value = "${module.nat.nat_eip_public_ip}"
}
output "nat_eip_instance_ids" {
  value = "${module.nat.nat_eip_instance_id}"
}
output "nat_eip_network_interface_ids" {
  value = "${module.nat.nat_eip_network_interface_id}"
}

output "nat_launch_configuration_ids" {
  value = "${module.nat.nat_launch_configuration_ids}"
}

output "asg_id" {
  value = "${module.nat.asg_id}"
}

output "asg_availability_zones" {
  value = "${module.nat.asg_availability_zones}"
}

output "asg_min_size" {
  value = "${module.nat.asg_min_size}"
}

output "asg_max_size" {
  value = "${module.nat.asg_max_size}"
}

output "asg_default_cooldown" {
  value = "${module.nat.asg_default_cooldown}"
}

output "asg_name" {
  value = "${module.nat.asg_name}"
}

output "asg_health_check_grace_period" {
  value = "${module.nat.asg_health_check_grace_period}"
}

output "asg_health_check_type" {
  value = "${module.nat.asg_health_check_type}"
}

output "asg_desired_capacity" {
  value = "${module.nat.asg_desired_capacity}"
}

output "asg_launch_configuration" {
  value = "${module.nat.asg_launch_configuration}"
}

output "asg_vpc_zone_identifier" {
  value = "${module.nat.asg_vpc_zone_identifier}"
}

output "asg_load_balancers" {
  value = "${module.nat.asg_load_balancers}"
}

output "aws_nat_eni_iam_role_id" {
  value = "${module.nat.aws_nat_eni_iam_role_id}"
}

output "aws_nat_eni_iam_role_arn" {
  value = "${module.nat.aws_nat_eni_iam_role_arn}"
}

output "nat_attach_eni_policy_id" {
  value = "${module.nat.nat_attach_eni_policy_id}"
}

output "nat_attach_eni_policy_name" {
  value = "${module.nat.nat_attach_eni_policy_name}"
}

output "nat_attach_eni_policy_policy" {
  value = "${module.nat.nat_attach_eni_policy_policy}"
}

output "nat_attach_eni_policy_role" {
  value = "${module.nat.nat_attach_eni_policy_role}"
}

output "attach_eni_profile_instance_id" {
  value = "${module.nat.attach_eni_profile_instance_id}"
}

output "attach_eni_profile_arn" {
  value = "${module.nat.attach_eni_profile_arn}"
}

output "attach_eni_profile_create_date" {
  value = "${module.nat.attach_eni_profile_create_date}"
}

output "attach_eni_profile_name" {
  value = "${module.nat.attach_eni_profile_name}"
}

output "attach_eni_profile_path" {
  value = "${module.nat.attach_eni_profile_path}"
}

output "attach_eni_profile_roles" {
  value = "${module.nat.attach_eni_profile_roles}"
}

output "attach_eni_profile_unique_id" {
  value = "${module.nat.attach_eni_profile_unique_id}"
}

######################################################################
# Route53 Module Outputs
##
output "dns_domain_name" {
     value = "${module.dns.dns_domain_name}"
}

output "dns_domain_id" {
     value = "${module.dns.dns_domain_id}"
}

output "dhcp_options_id" {
     value  = "${module.dns.dhcp_options_id}"
}


