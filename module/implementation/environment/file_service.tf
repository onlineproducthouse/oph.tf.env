#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "file_service" {
  source = "../../../module/implementation/shared/storage"
  storage = {
    bucket_name = "${local.shared_name}-fs"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  file_service_output = {
    bucket_name = module.file_service.id
    bucket_arn  = module.file_service.arn
  }
}
