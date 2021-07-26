
#  kept at environment level since its common per environment

#  connection info for the current environment
#  parse this go template before push
#  this creates a "backend.tf" file
remote_state {
  backend = "pg" 
  config = {
    conn_str = "postgres://{{.BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.Organization.Name}}"
    schema_name = "tf_{{.Environment.Name}}_${replace(replace(path_relative_to_include(), "/", "__"), "..", "")}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}