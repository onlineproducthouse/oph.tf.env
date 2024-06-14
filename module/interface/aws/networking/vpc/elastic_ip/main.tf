#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "elastic_ip" {
  type = object({
    subnet_count = number
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_eip" "elastic_ip" {
  count  = var.elastic_ip.subnet_count
  domain = "vpc"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "eip_public_ip_list" {
  value = aws_eip.elastic_ip.*.public_ip
}

output "eip_public_ipv4_pool_list" {
  value = aws_eip.elastic_ip.*.public_ipv4_pool
}

output "eip_nat_id_list" {
  value = aws_eip.elastic_ip.*.id
}
