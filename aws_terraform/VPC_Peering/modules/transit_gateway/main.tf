# Transport Gateway (VPC 1 communicate to VPC 2)

resource "aws_ec2_transit_gateway" "Transit-Gateway-1" {
  description = "Transit Gateway"

  tags = {  
    Name = "${var.proj_name}-Transit-Gateway-1"
  }
}

# resource "aws_ec2_transit_gateway_route_table" "Transit-Gateway-1-RT-Pre-Inspection" {
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
# }

# resource "aws_ec2_transit_gateway_route_table" "Transit-Gateway-1-RT-Post-Inspection" {
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
# }

# resource "aws_ec2_transit_gateway_route" "main" {
#     destination_cidr_block = var.vpc_2_cidr_range
#     transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachment.id
#     transit_gateway_route_table_id = aws_ec2_transit_gateway.Transit-Gateway-1.association_default_route_table_id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "Transit-Gateway-1-RT-Prop-Pre" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Transit-Gateway-1-RT-Pre-Inspection.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "Transit-Gateway-1-RT-Prop-Post" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Transit-Gateway-1-RT-Post-Inspection.id
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
  subnet_ids         = [ var.vpc_1_subnet ]
  transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
  vpc_id             = var.vpc_1_id
  tags = {  
    Name = "${var.proj_name}-VPC1-Transit-Gateway-Attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment_2" {
  subnet_ids         = [ var.vpc_2_subnet ]
  transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
  vpc_id             = var.vpc_2_id
  tags = {  
    Name = "${var.proj_name}-VPC2-Transit-Gateway-Attachment"
  }
}

resource "aws_route_table" "vpc1_to_vpc2_rt" {
  vpc_id = var.vpc_1_id

  route {    
    cidr_block = var.vpc_2_cidr_range    
    transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
  }  
  tags = {
    Name = "${var.proj_name}-vpc1-vpc2-rt"
  }
}

resource "aws_route_table" "vpc2_to_vpc1_rt" {
  vpc_id = var.vpc_2_id

  route {    
    cidr_block = var.vpc_1_cidr_range    
    transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
  }  
  tags = {
    Name = "${var.proj_name}-vpc2-vpc1-rt"
  }
}

resource "aws_route_table_association" "rtb_association_vpc_1" {
  subnet_id      = var.vpc_1_subnet 
  route_table_id = aws_route_table.vpc1_to_vpc2_rt.id
}

resource "aws_route_table_association" "rtb_association_vpc_2" {
  subnet_id      = var.vpc_2_subnet 
  route_table_id = aws_route_table.vpc2_to_vpc1_rt.id
}

# Transit Gateway VPC Attachment

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_ingress_attachment" {
#   subnet_ids         = [ var.vpc_1_subnet ]
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
#   vpc_id             = var.vpc_1_id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_egress_attachment" {
#   subnet_ids         = [ var.vpc_1_subnet ]
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
#   vpc_id             = var.vpc_1_id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_inspection_attachment" {
#   subnet_ids         = [ var.vpc_1_subnet ]
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-1.id
#   vpc_id             = var.vpc_1_id
# }




# Transport Gateway (VPC 2 communicate to VPC 1)

# resource "aws_ec2_transit_gateway" "Transit-Gateway-2" {
#   description = "Transit Gateway 2 provides communication route from VPC 2 to VPC 1"

#   tags = {  
#     Name = "${var.proj_name}-Transit-Gateway-2"
#   }
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "Transit-Gateway-2-RT-Prop" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Transit-Gateway-2-RT.id
# }

# resource "aws_ec2_transit_gateway_route_table" "Transit-Gateway-2-RT" {
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-2.id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_attachment" {
#   subnet_ids         = [ var.vpc_2_subnet ]
#   transit_gateway_id = aws_ec2_transit_gateway.Transit-Gateway-2.id
#   vpc_id             = var.vpc_2_id
# }