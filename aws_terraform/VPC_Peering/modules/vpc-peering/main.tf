resource "aws_vpc_peering_connection" "main" {
  # peer_owner_id = var.peer_owner_id (Use Default)
  peer_vpc_id   = var.vpc_2_id
  vpc_id        = var.vpc_1_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between VPC 1 and VPC 2"
  }
}

# resource "aws_vpc_peering_connection_options" "vpc_peering_connection_options" {
#   vpc_peering_connection_id = aws_vpc_peering_connection.main.id

#   accepter {
#     allow_remote_vpc_dns_resolution = true
#   }

#   requester {
#     allow_vpc_to_remote_classic_link = true
#     allow_classic_link_to_remote_vpc = true
#   }
# }

resource "aws_route_table" "vpc1_to_vpc2_rt" {
  vpc_id = var.vpc_1_id

  route {    
    cidr_block = var.vpc_2_cidr_range    
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }  
  tags = {
    Name = "${var.proj_name}-vpc1-vpc2-rt"
  }
}