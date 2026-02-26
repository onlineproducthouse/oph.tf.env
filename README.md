# OPH DevOps Terraform Modules
This module provisions resources for running container applications and static websites on AWS, for a given environment e.g. "prod".

## Installation
After you setup the configuration, see usage below, run `terraform init` to install module as a dependency.

## Usage
See [example/main.tf](./example/main.tf) for an example configuration.

## How it works
This module is made of three layers, that is:
1. Network - base layer of networking infrastructure for the typical container applications. [Read more here.](./modules/network/README.md)
2. Platform - a layer provisioned on an existing network. this layer aims to provide services that are required by projects to execute their operations. [Read more here.](./modules/platform/README.md)
3. Project - this layer provisions project specific infrastructure on an existing platform. only "runtime" infrastructure is provisioned on this layer. [Read more here.](./modules/project/README.md):
   1. API (container)
   2. Batch (container)
   3. Web (static website)

### What is a switchboard?

A switchboard is a set of variables in each module, prefixed with `sb_`, that determine the resources that must be provisioned. Each module's switchboard will be unique to its resources and managed indepedently, so the user is expected to ensure they supply the correct `sb_` variables for a given module.

A switchboard enables the provisioning of resources based on what is required while continuing to only run the `terraform apply` command for as long the resources are required. However, the switchboard will instead dictate which resources to provision or destroy.

## Contributing
Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
