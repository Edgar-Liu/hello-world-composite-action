variable "vpc_id" {}

variable "subnet" {
    type = map(
        object(
            {
                name                = string
                cidr_block          = string
                availability_zone   = string
            }
        )
    )
}

variable "proj_name" {}