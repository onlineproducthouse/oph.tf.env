locals {
  users = [
    {
      username = "bongani",
      group_list = [
        data.terraform_remote_state.groups.outputs.groups["developer"].name,
        data.terraform_remote_state.groups.outputs.groups["operations"].name,
      ],
    }
  ]
}