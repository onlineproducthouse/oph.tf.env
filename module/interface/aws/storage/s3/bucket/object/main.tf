#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "object" {
  type = object({
    key         = string
    bucket_id   = string
    source_path = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_object" "object" {
  bucket                 = var.object.bucket_id
  key                    = var.object.key
  source                 = var.object.source_path
  server_side_encryption = "AES256"
  etag                   = filemd5(var.object.source_path)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "key" {
  value = aws_s3_object.object.id
}
