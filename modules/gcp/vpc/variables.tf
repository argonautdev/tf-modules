variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "region" {
  type        = string
  description = "Region in which to deploy the resources"
}

variable "network_name" {
  description = "The name of the network being created"
  type        = string
}

variable "subnets" {
  type        = list(object({ 
      subnet_name = string, 
      subnet_ip = string, 
      subnet_region = string, 
      subnet_private_access = bool, 
      subnet_flow_logs = bool, 
      description = string
  }))
  default     = []
  description = "The list of subnets being created"
}

variable "description" {
  type        = string
  description = "An optional description of this resource. The resource must be recreated when modify this field."
  default     = ""
}

######################################
# Nat & Cloud route creation variables
######################################
variable "router_name" {
  type        = string
  description = "Name of the router"
}

variable "router_description" {
  type        = string
  description = "An optional description of this resource"
  default     = null
}

# Type: list(object), with fields:
# - name (string, required): Name of the NAT.
# - nat_ip_allocate_option (string, optional): How external IPs should be allocated for this NAT. Defaults to MANUAL_ONLY if nat_ips are set, else AUTO_ONLY.
# - source_subnetwork_ip_ranges_to_nat (string, optional): How NAT should be configured per Subnetwork. Defaults to ALL_SUBNETWORKS_ALL_IP_RANGES. values can be Possible values are ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, and LIST_OF_SUBNETWORKS.
# - nat_ips (list(number), optional): Self-links of NAT IPs.
# - min_ports_per_vm (number, optional): Minimum number of ports allocated to a VM from this NAT.
# - udp_idle_timeout_sec (number, optional): Timeout (in seconds) for UDP connections. Defaults to 30s if not set.
# - icmp_idle_timeout_sec (number, optional): Timeout (in seconds) for ICMP connections. Defaults to 30s if not set.
# - tcp_established_idle_timeout_sec (number, optional): Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set.
# - tcp_transitory_idle_timeout_sec (number, optional): Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set.
# - log_config (object, optional):
#    - filter: Specifies the desired filtering of logs on this NAT. Defaults to "ALL".
# - subnetworks (list(objects), optional):
#   - name (string, required): Self-link of subnetwork to NAT.
#   - source_ip_ranges_to_nat (string, required): List of options for which source IPs in the subnetwork should have NAT enabled. Supported values include: ALL_IP_RANGES, LIST_OF_SECONDARY_IP_RANGES, PRIMARY_IP_RANGE
#   - secondary_ip_range_names (string, optional): List of the secondary ranges of the subnetwork that are allowed to use NAT.
variable "nats" {
  description = "NATs to deploy on this router."
  type = list(object({
    name                               = string,
    source_subnetwork_ip_ranges_to_nat = string,
    nat_ip_allocate_option             = string,
  }))
}


#####################################################################################
# Reserved global compute address ( Internal ) Prefix length                       #
#####################################################################################
variable "prefix_length" {
  description = "Prefix length of the IP range reserved for Cloud SQL instances and other Private Service Access services. Defaults to /16"
  type = string
  default = 16
}