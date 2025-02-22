#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "ci" {
  type = object({
    name            = string
    region          = string
    build_timeout   = string
    is_docker_build = bool

    build_job = object({
      buildspec = string
      environment_variables = list(object({
        key   = string
        value = string
      }))
    })

    deploy_job = object({
      buildspec = string

      environment_variables = list(object({
        key   = string
        value = string
      }))

      deployment_targets = list(object({
        name = string // qa, prod
        vpc = object({
          id      = string
          subnets = list(string)
        })
      }))
    })

    pipeline = object({
      artifacts = object({
        source  = string
        build   = string
        release = string
      })

      git = object({
        connection_arn = string
        repo_name      = string
        branch_names   = list(string) # qa, prod
      })
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

output "pipeline" {
  value = local.pipeline_output
}
