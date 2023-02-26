#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "network" {
  value = {
    vpc_id = aws_vpc.vpc.id
    eip    = module.eip.eip_public_ip_list
    subnet_id_list = {
      private = module.private_subnet.id_list
      public  = module.public_subnet.id_list
    }
  }
}

# output "igw" {
#   value = {
#     id = aws_internet_gateway.igw.id
#   }
# }
