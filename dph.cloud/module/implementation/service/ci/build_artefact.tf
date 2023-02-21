#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################
variable "build_artefact" {
  type = object({
    name = string
  })

  default = {
    name = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "build_artefact" {
  source = "../../../../module/implementation/shared/storage/private_s3_bucket"

  count = var.config_switch.build_artefact == true ? 1 : 0

  bucket_name = var.build_artefact.name
  client_info = var.client_info
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "build_artefact" {
  value = module.build_artefact[0]
}
