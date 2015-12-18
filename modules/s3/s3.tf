resource "aws_vpc_endpoint" "private_s3" {
    vpc_id          = "${var.vpc_id}"
    service_name    = "com.amazonaws.${var.aws_region}.s3"
    route_table_ids = [ "${concat(split(",", var.pri_rtbl_id_list),split(",", var.pub_rtbl_id_list))}"]
}

output "s3_endpoint_ids" {
  value = "${aws_vpc_endpoint.private_s3.id}"
}
