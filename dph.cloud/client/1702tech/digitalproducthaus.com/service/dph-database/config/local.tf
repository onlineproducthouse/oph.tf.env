#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "local_env_vars" {
  source = "../../../../../../module/interface/aws/security/ssm/param_store"

  region = var.region

  owner            = var.owner
  environment_name = var.environment_name

  parameters = [
    { path : local.paths.local, key : "ENVIRONMENT_NAME", value : "local" },
    { path : local.paths.local, key : "DB_PROTOCOL", value : "postgres" },
    { path : local.paths.local, key : "DB_USERNAME", value : "root" },
    { path : local.paths.local, key : "DB_PASSWORD", value : "password" },
    { path : local.paths.local, key : "DB_HOST", value : "127.0.0.1" },
    { path : local.paths.local, key : "DB_PORT", value : "5432" },
    { path : local.paths.local, key : "DB_NAME", value : "LocalDB" },
    { path : local.paths.local, key : "IMAGE_REGISTRY_BASE_URL", value : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" },
  ]
}
