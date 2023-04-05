provider "aws" {
  region  = "ap-southeast-1"
  profile = var.profile_name
}

# Get local IP address
data "http" "icanhazip" {
  url = "https://ipv4.icanhazip.com/"
}

# Contains the VPCs, Security Groups
module "vpc" {
  source = "./modules/vpc"

  my_ip          = data.http.icanhazip.response_body
  proj_name      = var.proj_name
  vpc_cidr_block = var.vpc_cidr_block
}

module "vpc_2" {
  source = "./modules/vpc"

  my_ip          = data.http.icanhazip.response_body
  proj_name      = var.proj_name
  vpc_cidr_block = var.vpc_cidr_block_2
}

# Contains the subnets
module "subnet_1" {
  source = "./modules/subnet"

  vpc_id    = module.vpc.vpc_id
  proj_name = var.proj_name
  subnet    = var.subnet
}

# Contains the subnets
module "subnet_2" {
  source = "./modules/subnet"

  vpc_id    = module.vpc_2.vpc_id
  proj_name = var.proj_name
  subnet    = var.subnet_2
}

# Contains EC2s
module "vm_vpc_1" {
  source = "./modules/ec2"

  security_group_id           = module.vpc.vpc_web_sg_id
  subnet_id                   = module.subnet_1.pvt_subnet_web_id
  vm_name                     = "VM-VPC-1"
  instance_type               = "t2.micro"
  availability_zone           = "ap-southeast-1a"
  associate_public_ip_address = "false"
  proj_name                   = var.proj_name
  vpc_id                      = module.vpc.vpc_id
  # route_table_id              = module.subnet_1.pvt_route_table_id
}

module "vm_vpc_2" {
  source = "./modules/ec2"

  security_group_id           = module.vpc_2.vpc_web_sg_id
  subnet_id                   = module.subnet_2.pvt_subnet_web_id
  vm_name                     = "VM-VPC-2"
  instance_type               = "t2.micro"
  availability_zone           = "ap-southeast-1a"
  associate_public_ip_address = "false"
  proj_name                   = var.proj_name
  vpc_id                      = module.vpc_2.vpc_id
  # route_table_id              = module.subnet_2.pvt_route_table_id
}

module "transitGW" {
  source = "./modules/transit_gateway"

  proj_name    = var.proj_name
  vpc_1_id     = module.vpc.vpc_id
  vpc_2_id     = module.vpc_2.vpc_id
  vpc_1_subnet = module.subnet_1.pvt_subnet_web_id
  vpc_2_subnet = module.subnet_2.pvt_subnet_web_id
  vpc_1_cidr_range = var.vpc_cidr_block
  vpc_2_cidr_range = var.vpc_cidr_block_2
}

# module "vpc-peering" {
#   source = "./modules/vpc-peering"

#   proj_name    = var.proj_name
#   vpc_1_id     = module.vpc.vpc_id
#   vpc_2_id     = module.vpc_2.vpc_id
#   vpc_2_cidr_range = var.vpc_cidr_block_2
# }

