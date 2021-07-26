# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration
// account level specs kept here
locals {
  map_users = [
    {
      userarn = "arn:aws:iam::054565121117:user/surya"
      username = "surya"
      groups = ["system:masters"]
    }
  ]
  map_accounts = ["54565121117"]
}
