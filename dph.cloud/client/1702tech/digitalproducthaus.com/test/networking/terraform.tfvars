region           = "eu-west-1"
environment_name = "test"
owner            = "digitalproducthaus"

cidr_block = "10.0.0.0/16"

availibility_zones        = ["eu-west-1b", "eu-west-1c"]
private_subnet_cidr_block = ["10.0.50.0/24", "10.0.51.0/24"]
public_subnet_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24"]
