resource "aws_subnet" "pvt_subnet_web" {
  vpc_id = var.vpc_id

  cidr_block        = var.subnet.pvt_web.cidr_block
  availability_zone = var.subnet.pvt_web.availability_zone

  tags = {
    Name = "${var.proj_name}-${var.subnet.pvt_web.name}"
  }
}


# resource "aws_route_table" "private_rt" {
#   vpc_id = var.vpc_id

#   # route {    
#   #   cidr_block = "0.0.0.0/0"    
#   #   gateway_id = var.nat_gw_id
#   # }  
#   tags = {
#     Name = "${var.proj_name}-private-rt"
#   }
# }

# Private RT Association
# resource "aws_route_table_association" "rta_pvt_1" {
#   subnet_id      = aws_subnet.pvt_subnet_web.id
#   route_table_id = aws_route_table.private_rt.id
# }