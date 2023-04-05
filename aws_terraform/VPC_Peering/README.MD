## VPC Peering Training

The codes residing in VPC Peering spins up two EC2 Instances on separate VPCs, which aims to achieve ping success between each other.

## Some code commands which are commonly used 

``` terraform init -backend-config="backend.tfvars" ```
``` terraform plan -var-file="config.tfvars" -auto-approve ```
``` terraform destroy -var-file="config.tfvars" -auto-approve ```