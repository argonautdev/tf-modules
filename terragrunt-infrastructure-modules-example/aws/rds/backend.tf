terraform {
  backend "pg" {
    conn_str    = "postgres://{{.BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.Organization.Name}}"
    schema_name = "tf_{{.Environment.Name}}"
  }
}