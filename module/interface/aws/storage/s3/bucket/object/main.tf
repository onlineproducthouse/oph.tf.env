#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "object" {
  type = object({
    key            = string
    bucket_id      = string
    source_path    = string
    content_base64 = string
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
  source                 = var.object.source_path == null ? null : var.object.source_path
  content_base64         = var.object.content_base64 == null ? null : var.object.content_base64
  server_side_encryption = "AES256"
  etag                   = var.object.source_path == null ? null : filemd5(var.object.source_path)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "key" {
  value = aws_s3_object.object.id
}
