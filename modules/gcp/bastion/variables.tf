variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "region" {
  type        = string
  description = "Region in which to deploy the resources"
}

/* Bastion Details */

variable "image" {
  type = string

  description = "Source image for the Bastion. If image is not specified, image_family will be used (which is the default)."
  default     = ""
}

variable "image_family" {
  type = string

  description = "Source image family for the Bastion."
  default     = "ubuntu-1804-lts"
}

variable "image_project" {
  type = string

  description = "Project where the source image for the Bastion comes from"
  default     = "ubuntu-os-cloud"
}

variable "create_instance_from_template" {
  type        = bool
  description = "Whether to create and instance from the template or not. If false, no instance is created, but the instance template is created and usable by a MIG"
  default     = true
}

variable "bastion_host_name" {
  type        = string
  description = "Name of the Bastion instance. host name must follow the following constraints ^[a-z](?:[-a-z0-9]{4,28}[a-z0-9])$"
}

##############
##Network tags allows to have tags on enic's created by vm instance.
##the time we want apply firwalls we can use networks in firewalls to know on which instances the firewall should be applied.
##############
variable "tags" {
  type        = list(string)
  description = "Network tags, provided as a list"
  default     = []
}

variable "labels" {
  type        = map(any)
  description = "Key-value map of labels to assign to the bastion host"
  default     = {}
}

variable "machine_type" {
  type        = string
  description = "Instance type for the Bastion host"
  default     = "e2-medium"
}

variable "members" {
  type = list(string)

  description = "List of IAM resources to allow access to the bastion host"
  default     = []
}

variable "name_prefix" {
  type = string

  description = "Name prefix for instance template"
  default     = "bastion-instance-template"
}

variable "shielded_vm" {
  type        = bool
  description = "Enable shielded VM on the bastion host"
  default     = false
}

variable "startup_script" {
  type        = string
  description = "Render a startup script with a template."
  default     = ""
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  default     = 20
}

variable "disk_type" {
  description = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard"
  default     = "pd-balanced"
}

#################################################################################
# To Work with Os login we already enabling necessary key pairs in module itself#
# to know the importance of metadata read the following                         #
# https://cloud.google.com/compute/docs/metadata/overview?authuser=1&_ga=2.149899062.-1808336238.1654844270&_gac=1.152250187.1656062031.CjwKCAjwwdWVBhA4EiwAjcYJEJ8rwdz-VgvOLi6Bt0ayP0yup-DESR3a8zBUf-dEbXVEuiEFf-BX6BoCcGUQAvD_BwE
##################################################################################

variable "metadata" {
  type        = map(string)
  description = "Key-value map of additional metadata to assign to the instances"
  default     = {}
}

####################################################################
# We don't want to enable external ip.                             #
# IAP is used for accessing vms using internal ip. hence disabling #
####################################################################
variable "external_ip" {
  type        = bool
  description = "Set to true if an ephemeral or static external IP/DNS is required, must also set access_config if true"
  default     = false
}

variable "preemptible" {
  type        = bool
  description = "Allow the instance to be preempted"
  default     = false
}

variable "access_config" {
  description = "Access configs for network, nat_ip and DNS"
  type = list(object({
    network_tier           = string
    nat_ip                 = string
    public_ptr_domain_name = string
  }))
  default = [{
    nat_ip                 = "",
    network_tier           = "PREMIUM",
    public_ptr_domain_name = ""
  }]
}


/* Existing VPC & Subnetwork details */

variable "network" {
  type = string

  description = "Self link for the network on which the Bastion should live"
}

variable "subnet" {
  type        = string
  description = "Self link for the subnet on which the Bastion should live. Can be private when using IAP"
}

########################################
# Pass Name for firwall rule ###########
#######################################
variable "create_firewall_rule" {
  type        = bool
  description = "If we need to create the firewall rule or not."
  default     = true
}

variable "fw_name_allow_ssh_from_iap" {
  type        = string
  description = "Firewall rule name for allowing SSH from IAP"
}

variable "additional_ports" {
  description = "A list of additional ports/ranges to open access to on the instances from IAP."
  type        = list(string)
  default     = []
}

/* Bastion Host service account details */

variable "scopes" {
  type = list(string)

  description = "List of scopes to attach to the bastion host"
  default     = ["cloud-platform"]
}

variable "service_account_roles" {
  type = list(string)

  description = "List of IAM roles to assign to the service account."
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin",
  ]
}

##Additionally allowing container admin, so that we can run kubectl commands by download kubeconfig file to bastion
variable "service_account_roles_supplemental" {
  type        = list(string)
  description = "An additional list of roles to assign to the bastion if desired"
  default = [
    "roles/container.admin" ##Provides access to full management of clusters and their Kubernetes API objects.
  ]
}

##Make sure pass service account name
variable "service_account_name" {
  type        = string
  description = "Account ID for the service account"
}

variable "service_account_email" {
  type = string

  description = "If set, the service account and its permissions will not be created. The service account being passed in should have at least the roles listed in the `service_account_roles` variable so that logging and OS Login work as expected."
  default     = ""
}




