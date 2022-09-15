# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration
// account level specs kept here
locals {
  map_roles = [
    {{ if .ProviderDetails.AWSRoleArn }}
    {
      rolearn = "{{.ProviderDetails.AWSRoleArn}}"
      username = "system:masters"
      groups = ["system:masters"]
    }
    {{ end }}
  ]
  map_users = [
    {{ if .ProviderDetails.AWSArn }}
    {
      userarn = "{{.ProviderDetails.AWSArn}}"
      username = "{{.ProviderDetails.Username}}"
      groups = ["system:masters"]
    }
    {{ end }}
  ]
  map_accounts = ["{{.ProviderDetails.AWSAccountID}}"]
}
