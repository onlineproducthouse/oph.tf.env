#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "compute" {
  type = object({
    run = bool

    name   = string
    region = string

    cloud = object({
      private_subnet_id_list = list(string)
    })

    image_id      = string
    instance_type = string

    auto_scaling = object({
      minimum = number
      maximum = number
      desired = number
    })

    vpc_security_group_ids = list(string)

    aws_iam_instance_profile_arn = string
    task_role_arn                = string

    logging = object({
      prefix = string
      group  = string
      driver = string
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

output "compute" {
  value = local.compute_output
}
