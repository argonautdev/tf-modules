include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/cloud_composer_v2?ref={{.RefVersion}}"
}

dependency "{{.Spec.vpc_id}}" {
  config_path = "../vpc_{{.Spec.vpc_id}}"
}

inputs = {
  default_labels = {
    "argonaut-id"          = "{{.Spec.id}}"
    "argonaut-name"        = "{{.Spec.name}}"
    "argonaut-type"        = "gke"
    "argonaut-manager"     = "argonaut-dev"
    "argonaut-environment" = "{{.Environment.Name}}"
  }
  vpc_network_name               = dependency.{{ .Spec.vpc_id }}.outputs.network_name
}
