# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration
// account level specs kept here
locals {
  map_roles = [
    {{ if .AWS.AWSRoleArn }}
    {
      rolearn = "{{.AWS.AWSRoleArn}}"
      username = "system:masters"
      groups = ["system:masters"]
    }
    {{ end }}
  ]
  map_users = [
    {{ if .AWS.AWSArn }}
    {
      userarn = "{{.AWS.AWSArn}}"
      username = "{{.AWS.Username}}"
      groups = ["system:masters"]
    }
    {{ end }}
  ]
  map_accounts = ["{{.AWS.AWSAccountID}}"]
}
