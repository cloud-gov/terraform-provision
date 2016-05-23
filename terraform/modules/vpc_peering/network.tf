
# Create peering connection for source_vpc_id -> target_vpc_id
resource "aws_vpc_peering_connection" "peering" {
    peer_owner_id = "${var.peer_owner_id}"
    peer_vpc_id = "${var.target_vpc_id}"
    auto_accept = true
    vpc_id = "${var.source_vpc_id}"

    tags = {
        Name = "${var.source_vpc_id} to ${var.target_vpc_id}"
    }
}

# Add peering connection to target_az1_route_table with source_vpc_cidr
resource "aws_route" "target_az1_to_source_cidr" {
    route_table_id = "${var.target_az1_route_table}"
    destination_cidr_block = "${var.source_vpc_cidr}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}

# Add peering connection to target_az2_route_table with source_vpc_cidr
resource "aws_route" "target_az2_to_source_cidr" {
    route_table_id = "${var.target_az2_route_table}"
    destination_cidr_block = "${var.source_vpc_cidr}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}

# add peering connection to source_az1_route_table with target_vpc_cidr
resource "aws_route" "source_az1_to_target_cidr" {
    route_table_id = "${var.source_az1_route_table}"
    destination_cidr_block = "${var.target_vpc_cidr}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}

# add peering connection to source_az2_route_table with target_vpc_cidr
resource "aws_route" "source_az2_to_target_cidr" {
    route_table_id = "${var.source_az2_route_table}"
    destination_cidr_block = "${var.target_vpc_cidr}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}