## to change values, go to "terraform.tfvars"

variable "profile_name" {
  description = "Name of your Profile. This profile is the AWS Profile created on your AWS CLI"
}

variable "proj_name" {
  description = "Name of your Project. The proj_name will be appended to each resource name when created."
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
}

variable "vpc_cidr_block_2" {
  description = "VPC_2 CIDR Block"
}

variable "subnet" {
  type = map(
    object(
      {
        name              = string
        cidr_block        = string
        availability_zone = string
      }
    )
  )
}

variable "subnet_2" {
  type = map(
    object(
      {
        name              = string
        cidr_block        = string
        availability_zone = string
      }
    )
  )
}

# variable "key_pair_arn" {
#   description = "ARN of the Secret (SSH-KEY VALUE)"
# }

# variable "key_pair"{
#   description = "Name of your key pair to connect to instance"
# }

# # Database Variables
# variable "db_name" {
#   description = "Name of your database"
#   default = "RDS"
# }

# variable "db_engine_type" {
#   description = "Type of your database (E.g. postgres)"
#   default = "postgres"
# }

# variable "db_engine_version" {
#   description = "Engine Version. Refer to the versions available for selected engine type"
#   default = "13.7"
# }

# variable "db_instance_class" {
#   description = "DB Instance Class. Determines the computation and memory capacity of an Amazon RDS DB instance. (general purpose, memory-optimized, and burstable performance)"
#   default = "db.t3.micro"
# }

# variable "db_username" {
#   description = "Username to login to database"
# }

# variable "db_password" {
#   description = "Password to login to database"
# }

# variable "db_allocated_storage" {
#   description = "Storage provided is in Gigabytes (GB)"
# }