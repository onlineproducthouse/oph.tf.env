#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "versioning" {
  type = object({
    bucket_id = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = var.versioning.bucket_id

  versioning_configuration {
    status = "Enabled"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################


