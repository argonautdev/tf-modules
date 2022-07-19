include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/vpc?ref={{.RefVersion}}"
}

inputs = {
  source       = "./modules/gcp/vpc"
  default_tags = {
    "argonaut.dev/id"        = "{{.Spec.id}}"
    "argonaut.dev/name"        = "{{.Spec.name}}"
    "argonaut.dev/type"        = "VPC"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "{{.Environment.Name}}"
  }
  project_id   = "{{.Spec.project_id}}"
  region       = "us-east4"
  network_name = "{{.Spec.network_name}}"
  description  = "{{.Spec.description}}"
  subnets = [{{ range $subnet := .Spec.subnets }}
    {
      subnet_name           = "{{$subnet.subnet_name}}"
      subnet_ip             = "{{$subnet.subnet_ip}}"
      subnet_region         = "{{$subnet.subnet_region}}"
      subnet_private_access = {{$subnet.subnet_private_access}}
      subnet_flow_logs      = "{{$subnet.subnet_flow_logs}}"
      description           = "{{$subnet.description}}"
    },
    {{ end }}
  ]

  router_description = "{{.Spec.router_description}}"
  router_name        = "{{.Spec.router_name}}"
  nats = [{{ range $nat := .Spec.nats }}
    {
      "name" : "{{$nat.name}}",
      "nat_ip_allocate_option" : "{{$nat.nat_ip_allocate_option}}",
      "source_subnetwork_ip_ranges_to_nat" : "{{$nat.source_subnetwork_ip_ranges_to_nat}}"
    },
    {{ end }}
  ]
}