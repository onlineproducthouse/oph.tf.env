# OPH Environment Terraform Modules

This modules provisions all required resources for OPH applications. The resources provisioned address application requirements in a given environment. The environment is composed of a network, platform and projects.

## Usage

There are two ways to consume this module, that is:
1. Use root module to provision the entire environment.
2. Use specific module directly.

The architecture provisioned here is distinguished between three layers, namely:

1. Network layer - base layer of networking infrastructure for the typical container applications. [Read more here.](./modules/network/README.md)

2. Platform layer - a layer provisioned on an existing network. this layer aims to provide services that are required by projects to execute their operations. [Read more here.](./modules/platform/README.md)

3. Project layer - this layer provisions project specific infrastructure on an existing platform. only "runtime" infrastructure is provisioned on this layer. [Read more here.](./modules/project/README.md)

Our recommendation is to use the root version if you don't have already components you wish to use. Each subsequent layer depends on one or more layers, with the network layer as the base. The platform layer is built on top of the network layer, and project layer on top of the playform layer.

This means, in the event you wish to use one layer and not another, the requirements of that layer must be met whether the suppoting native module is used or not.

## Switchboard 🎛️

### History

When deploying terraform resources, we believe that `terraform apply` must be executed when the module is provisioned and `terraform destroy` when the module's resources are taken down. The concept of provisioning a resource means that the user is using the `terraform apply` command to provision resources and will continue to use this command for as long as the resources are required or in use.

As a result of this, `terraform apply` then needs to cater to both creation and modification of provisioned resources.

In an effort to minimise cloud infrastructure costs, each module previously maintained a `run` variable to indicate whether that module may be provisioned or not. Because every change to the infrastructure, including this variable, was managed using the `terraform apply` command, this enabled us to only use `terraform destroy` when we certainly no longer required the resources provisioned.

This variable effectively meant that the states of the modules were:
1. offline - resources are not provisioned
2. dormant - resources are provisioned, but the `run` variable is set to `false`
3. online - resources are provisioned and the `run` variable is set to `true`

The benefits from this approach where twofold:
1. We can provision resources only as and when needed
2. We can leave resources permanently provisioned either because it has no costly or maintaining its provision is of strategic importance

This approach presented limitations because it was primarily base on managing infrastructure costs.

For simplicity's sake, the negative impact on strategically important components to a business, such as IP addresses, was compromised. Furthermore this approach meant that some resources could not be provisioned if depending on a costly resource, and therefore one could not choose which costly services they are will to bear the expense of.

### What is a switchboard?

A switchboard is a set of variables in each module, prefixed with `sb_`, that determines the resources that must be provisioned. Each module's switchboard will be unique to its resources and managed indepedently, so the user is expected to ensure correlation among dependencies of one resource and another.

A switchboard enables the provisioning of resources based on what is required while continuing to only run the `terraform apply` command for as long the resources are required. However, the switchboard will instead dictate which resources to provision or destroy.
