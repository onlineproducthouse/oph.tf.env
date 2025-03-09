#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "ci" {
  type = object({
    name         = string
    region       = string
    is_container = bool

    jobs = object({
      build = list(object({
        buildspec   = string
        timeout     = string
        branch_name = string

        environment_variables = list(object({
          key   = string
          value = string
        }))
      }))

      release = list(object({
        name             = string
        buildspec        = string
        timeout          = string
        branch_name      = string
        environment_name = string

        environment_variables = list(object({
          key   = string
          value = string
        }))

        vpc = object({
          id      = string
          subnets = list(string)
        })
      }))
    })
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  release_manifest = "ReleaseManifest.sh"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "role" {
  value = local.role_output
}

output "registry" {
  value = local.registry_output
}

output "build_artefact" {
  value = local.build_artefact_output
}

output "build_job" {
  value = local.build_job_output
}

output "release_job" {
  value = local.release_job_output
}
