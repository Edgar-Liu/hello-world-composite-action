#Profile Name
profile_name = "edgar"

#Project Name
proj_name = "VPC_Peering"

#vpc
vpc_cidr_block = "10.0.0.0/16"
vpc_cidr_block_2 = "10.1.0.0/16"


#subnet
subnet = {
    "pvt_web" : {
        "name" : "private_subnet_web",
        "cidr_block" : "10.0.0.0/24", 
        "availability_zone" : "ap-southeast-1a"
    }     
}

subnet_2 = {
    "pvt_web" : {
        "name" : "private_subnet_web",
        "cidr_block" : "10.1.0.0/24", 
        "availability_zone" : "ap-southeast-1a"
    }     
}