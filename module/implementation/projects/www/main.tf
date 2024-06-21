#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "www" {
  type = object({
    run = bool

    host = object({
      index_page = string
      error_page = string
    })

    cdn = object({
      hosted_zone_id = string

      certificate = object({
        arn         = string
        domain_name = string
      })
    })
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "www" {
  value = {
    host = local.host_output
    cdn  = local.cdn_output
  }
}
