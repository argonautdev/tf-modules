include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/memorystore-memcache?ref={{.RefVersion}}"
}

dependency "{{.Spec.vpc_id}}" {
  config_path = "../vpc_{{.Spec.vpc_id}}"
}

inputs = {
  default_labels = {
    "argonaut-id"        = "{{.Spec.id}}"
    "argonaut-name"        = "{{.Spec.name}}"
    "argonaut-type"        = "memcached"
    "argonaut-manager"     = "argonautdev"
    "argonaut-environment" = "{{.Environment.Name}}"
  }
  project_id   = "{{.Spec.project_id}}"
  region       = "{{.Spec.region}}"
  name         = "{{.Spec.cluster_instance_name}}"
  node_count   = "{{.Spec.node_count}}"
  cpu_count    = "{{.Spec.cpu_count}}"
  memory_size_mb = "{{.Spec.memory_size_mb}}"
  zones       = "{{.Spec.zones}}"
  vpc_network_name = dependency.{{ .Spec.vpc_id }}.outputs.network_name
}
