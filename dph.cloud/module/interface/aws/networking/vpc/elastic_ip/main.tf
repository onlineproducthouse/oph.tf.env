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

variable "client_info" {
  type = object({
    region           = string
    owner            = string
    project_name     = string
    service_name     = string
    environment_name = string
  })

  default = {
    region           = ""
    owner            = ""
    project_name     = ""
    service_name     = ""
    environment_name = ""
  }
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
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
    environment_name = var.client_info.environment_name
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
