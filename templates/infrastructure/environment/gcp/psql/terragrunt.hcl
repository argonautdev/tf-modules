include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/psql?ref={{.RefVersion}}"
}

dependency "{{.Spec.vpc_id}}" {
  config_path = "../vpc_{{.Spec.vpc_id}}"
}

inputs = {
  default_labels = {
    "argonaut-id"        = "{{.Spec.id}}"
    "argonaut-name"        = "{{.Spec.name}}"
    "argonaut-type"        = "psql"
    "argonaut-manager"     = "argonautdev"
    "argonaut-environment" = "{{.Environment.Name}}"
  }
  
  vpc_network_name               = dependency.{{ .Spec.vpc_id }}.outputs.network_name
}
