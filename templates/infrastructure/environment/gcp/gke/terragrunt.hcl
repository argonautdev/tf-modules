include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/gke?ref={{.RefVersion}}"
}

dependency "{{.Spec.vpc_id}}" {
  config_path = "../vpc_{{.Spec.vpc_id}}"
  }
}

inputs = {
  default_labels = {
    "argonaut.dev/id"        = "{{.Spec.id}}"
    "argonaut.dev/name"        = "{{.Spec.name}}"
    "argonaut.dev/type"        = "GKE"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "{{.Environment.Name}}"
  }
  project_id   = "{{.Spec.project_id}}"
  cluster_name = "{{.Spec.cluster_name}}"
  description  = "{{.Spec.description}}"
  region       = "{{.Spec.region}}"
  cluster_node_zones = [
    {{ range $cluster_node_zone := .Spec.cluster_node_zones }}"{{$cluster_node_zone}}",
    {{ end }}
  ]
  network_name               = dependency.{{ .Spec.vpc_id }}.outputs.network_name
  subnetwork_name            = "{{.Spec.subnetwork_name}}"
  pod_subnet_name            = "{{.Spec.pod_subnet_name}}"
  service_subnet_name        = "{{.Spec.service_subnet_name}}"
  subnetwork_cidr            = "{{.Spec.subnetwork_cidr}}"
  pod_subnet_cidr_block      = "{{.Spec.pod_subnet_cidr_block}}"
  service_subnet_cidr_block  = "{{.Spec.service_subnet_cidr_block}}"
  enable_private_endopoint   = {{.Spec.enable_private_endopoint}}
  enable_private_nodes       = {{.Spec.enable_private_nodes}}
  master_authorized_networks = [
    {{ range $master_authorized_network := .Spec.master_authorized_networks }}"{{$master_authorized_network}}",
    {{ end }}
  ]
  master_ipv4_cidr_block = "{{.Spec.master_ipv4_cidr_block}}"
  {{ if .Spec.http_load_balancing }}http_load_balancing={{.Spec.http_load_balancing}}{{end}}
  {{ if .Spec.filestore_csi_driver}}filestore_csi_driver={{.Spec.filestore_csi_driver}}{{end}}
  {{ if .Spec.enable_vertical_pod_autoscaling}}enable_vertical_pod_autoscaling={{.Spec.enable_vertical_pod_autoscaling}}{{end}}
  {{ if .Spec.horizontal_pod_autoscaling }}horizontal_pod_autoscaling={{.Spec.horizontal_pod_autoscaling}}{{end}}
  {{ if .Spec.kubernetes_version }}kubernetes_version={{.Spec.kubernetes_version}}{{ end }}
  {{ if .Spec.initial_node_count }}initial_node_count={{.Spec.initial_node_count}}{{ end }}
  {{ if .Spec.labels }}labels = {
    {{ range $key, $value := .labels }}"{{$key}}" = "{{$value}}",
    {{ end }}
  }{{ end }}
  node_pools = [{{ range $node_pool := .Spec.node_pools }}{
    {{ range $key, $value := $node_pool }}"{{$key}}" = "{{$value}},"
    {{ end }}
    },{{ end }}
  ]
  {{ if ne .Spec.remove_default_node_pool nil }}remove_default_node_pool={{.Spec.remove_default_node_pool}}{{ end }}
  node_pools_labels = {
    {{range $node_pool_name, $node_pool_labels := .Spec.node_pools_labels}}"{{ $node_pool_name }}" = {
      {{range $label_key, $label_value := $node_pool_labels}}"{{$label_key}}" = "{{$label_value}}",
      {{end}}
    },
  {{end}}
  }
  node_pools_taints = {
  {{range $node_pool_name, $node_pool_taints := .Spec.node_pools_taints }}"{{ $node_pool_name }}" = [
    {{ range $taint := $node_pool_taints }}{
      key    = "$taint.key",
      value  = "$taint.value",
      effect = "$taint.effect",
    },
    {{ end }}
    ],
  {{end}}
  }
  node_pools_tags = {
  {{range $node_pool_name, $node_pool_tags := .Spec.node_pools_tags}}"
    {{ $node_pool_name }}" = [
      {{ range $node_pool_tag := range $node_pool_tags }}"{{$node_pool_tag}}",
      {{ end}}
    ],
  {{end}}
  }
  {{if .Spec.default_max_pods_per_node}}default_max_pods_per_node = {{ .Spec.default_max_pods_per_node }}{{end}}
  {{if .Spec.grant_registry_access}}grant_registry_access = {{ .Spec.grant_registry_access }}{{ end }}
  {{if .Spec.registry_project_ids}}registry_project_ids = {{ .Spec.registry_project_ids }}{{ end }}
}
