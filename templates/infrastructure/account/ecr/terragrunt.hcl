
locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  map_users    = local.account_vars.locals.map_users
  map_accounts = local.account_vars.locals.map_accounts

}

remote_state {
  backend = "pg" 
  config = {
    conn_str = "postgres://{{.BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.Organization.Name}}"
    schema_name = "tf_{{.Organization.OrganizationID}}_ecr"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/ecr?ref={{.RefVersion}}"
  # source = "../../../../../../modules/aws/ecr"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/type"        = "ecr"
    "argonaut.dev/manager"     = "argonaut.dev"
  }
  repositories = [
    {{range $e := .Ecr.Repositories }}{
      name                 = "{{$e.Name}}"
      image_tag_mutability = "{{ if $e.ImageTagMutability }}{{ $e.ImageTagMutability }}{{ else }}MUTABLE{{ end }}"
      scan_on_push         = {{ if $e.ScanOnPush }}{{ $e.ScanOnPush }}{{ else }}true{{ end }}
      encryption_type      = "{{ if $e.EncryptionType }}{{ $e.EncryptionType }}{{ else }}AES256{{ end }}"
      kms_key              = {{ if $e.KmsType }}{{ $e.KmsType }}{{ else }}null{{ end }}
      timeouts_delete      = "{{ if $e.TimeoutsDelete}}{{ $e.TimeoutsDelete}}{{ else }}60m{{ end }}"
      policy               = {{if $e.Policy}}{{ $e.Policy }}{{ else }}null{{ end }}
      lifecycle_policy     = {{if $e.LifecyclePolicy}}{{ $e.LifecyclePolicy }}{{ else }}null{{ end }}
    },
    {{end}}
  ]
  aws_region                 = "us-east-1"
  cross_replication = [
    {{ range $e := .Ecr.Replication }}{
      region = "{{$e.Region}}"
    },
    {{ end }}
  ]
}
