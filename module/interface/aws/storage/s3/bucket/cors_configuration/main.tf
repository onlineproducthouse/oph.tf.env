#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "cors_configuration" {
  type = object({
    bucket_id = string
    rules = list(object({
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = list(string)
      max_age_seconds = number
    }))
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket_cors_configuration" "cors_configuration" {
  count  = length(var.cors_configuration.rules) > 0 ? 1 : 0
  bucket = var.cors_configuration.bucket_id

  dynamic "cors_rule" {
    for_each = var.cors_configuration.rules

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################


