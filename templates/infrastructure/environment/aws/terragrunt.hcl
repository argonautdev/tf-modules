
#  Kept at environment-region level since its common per environment

#  connection info for the current environment
#  parse this go template before push
#  this creates a "backend.tf" file
remote_state {
  backend = "pg" 
  config = {
    conn_str = "postgres://{{.BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.BackendData.DatabaseName}}"
    schema_name = "tf_{{ .Environment.Name }}_${replace(replace(path_relative_to_include(), "/", "__"), "..", "")}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# a hook which deletes the resource folder after the deletion has completed
# terraform {
#   after_hook "delete_from_github" {
#     commands = ["destroy"]
#     execute  = ["curl", "--fail-with-body", "-X", "DELETE", "${get_env("MIDGARD_HOST_URL")}/api/v1/environment/github/delete/{{ .Environment.Name }}/{{ .Region }}/${basename(get_terragrunt_dir())}", "-H", "Content-Type: application/json", "-H", "Authorization: ${get_env("AUTHORIZATION")}" ]
#   }
# }