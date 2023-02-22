#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "key" {
  type    = string
  default = ""
}

variable "bucket_id" {
  type    = string
  default = ""
}

variable "source_path" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_object" "obj" {
  bucket                 = var.bucket_id
  key                    = var.key
  source                 = var.source_path
  server_side_encryption = "AES256"
  etag                   = filemd5(var.source_path)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "key" {
  value = aws_s3_object.obj.id
}
