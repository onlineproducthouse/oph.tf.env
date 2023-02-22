#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "db_certs" {
  type = object({
    test = object({
      source_path = string
    })
  })

  default = {
    test = {
      source_path = ""
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "store" {
  source = "../../../../module/implementation/shared/storage/private_s3_bucket"

  bucket_name = "${var.client_info.project_short_name}-${var.client_info.service_name}-ci-store"
  client_info = var.client_info
}

module "db_cert_test" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  count = var.db_certs.test.source_path == "" ? 0 : 1

  bucket_id   = module.store.id
  key         = "/${var.client_info.owner}/${var.client_info.project_short_name}/${var.client_info.service_name}/db-cert.crt"
  source_path = var.db_certs.test.source_path
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "store" {
  value = module.store
}

output "db_certs" {
  value = {
    test = module.db_cert_test[0]
  }
}
