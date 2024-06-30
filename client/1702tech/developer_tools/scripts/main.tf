#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/developer_tools/scripts/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/developer_tools/storage/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "scripts" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/scripts/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "script" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  for_each = {
    for script in data.terraform_remote_state.scripts.outputs.scripts : script.name => script
  }

  object = {
    bucket_id      = data.terraform_remote_state.storage.outputs.id
    key            = each.value.key
    source_path    = null
    content_base64 = each.value.content_base64
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "scripts" {
  value = {
    for script in data.terraform_remote_state.scripts.outputs.scripts : script.name => {
      key = module.script[script.name].key
      url = "s3://${data.terraform_remote_state.storage.outputs.id}${module.script[script.name].key}"
    }
  }
}
