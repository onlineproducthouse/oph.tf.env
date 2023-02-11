#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "subnet_count" {
  type        = number
  default     = 0
  description = "Size of the subnet_ids. This needs to be provided because: value of 'count' cannot be computed"
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_eip" "eip" {
  count = var.subnet_count

  vpc = true

  tags = {
    environment_name = var.environment_name
    owner            = var.owner
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "eip_public_ip_list" {
  value = aws_eip.eip.*.public_ip
}

output "eip_public_ipv4_pool_list" {
  value = aws_eip.eip.*.public_ipv4_pool
}

output "eip_nat_id_list" {
  value = aws_eip.eip.*.id
}
