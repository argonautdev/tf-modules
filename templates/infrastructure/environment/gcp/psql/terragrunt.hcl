include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/postgreSQL?ref={{.RefVersion}}"
}

dependency "{{.Spec.vpc_id}}" {
  config_path = "../vpc_{{.Spec.vpc_id}}"
}

inputs = {
  default_labels = {
    "argonaut.dev/id"        = "{{.Spec.id}}"
    "argonaut.dev/name"        = "{{.Spec.name}}"
    "argonaut.dev/type"        = "PSQL"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "{{.Environment.Name}}"
  }
  
  vpc_network_name               = dependency.{{ .Spec.vpc_id }}.outputs.network_name
}
