# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration
// account level specs kept here
locals {
  map_users = [
    {
      userarn = "{{.AWS.AWSArn}}"
      username = "{{.AWS.Username}}"
      groups = ["system:masters"]
    }
  ]
  map_accounts = ["{{.AWS.AWSAccountID}}"]
}
