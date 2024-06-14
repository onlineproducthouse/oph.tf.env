#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "encryption_configuration" {
  type = object({
    bucket_id = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  bucket = var.encryption_configuration.bucket_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################


