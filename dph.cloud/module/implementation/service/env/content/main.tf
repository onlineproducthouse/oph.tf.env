#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

variable "content" {
  type = object({
    db_cert_source_path = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "store" {
  source = "../../../../../module/implementation/shared/storage/private_s3_bucket"

  bucket_name = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}-store"
  client_info = var.client_info
}

module "db_cert" {
  source = "../../../../../module/interface/aws/storage/s3/bucket/object"

  count = var.content.db_cert_source_path == "" ? 0 : 1

  bucket_id   = module.store.id
  key         = "/${var.client_info.owner}/${var.client_info.project_short_name}/${var.client_info.service_name}/dbcert.crt"
  source_path = var.content.db_cert_source_path
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "store" {
  value = module.store
}

output "db_cert" {
  value = module.db_cert[0]
}
