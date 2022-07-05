module "vpc" {
    source = "./modules/gcp/vpc"
    project_id = "playground-351903"
    region = "us-east4"
    network_name = "dev-microservices-new-vpc"
    description = "custom vpc for kubernetes engine workloads"
    subnets = [
        {
           subnet_name = "dev-microservices-new-public-subnet"
           subnet_ip   = "10.10.0.0/16"
           subnet_region = "us-east4"
           subnet_private_access = false ##Setting to false as it should be act as public subnet
           subnet_flow_logs      = "false"
           description           = "Public subnets for running application frontend servers"
        },
        {
           subnet_name = "dev-microservices-new-private-subnets"
           subnet_ip   = "10.20.0.0/16"
           subnet_region = "us-east4"
           subnet_private_access = true
           subnet_flow_logs      = "false"
           description           = "Private subnets for running application backend servers"
        },
        {
           subnet_name = "dev-microservices-new-database-subnets"
           subnet_ip   = "10.30.0.0/16"
           subnet_region = "us-east4"
           subnet_private_access = true
           subnet_flow_logs      = "false"
           description           = "Subnets for running database. for instance, Cloud SQL"
        },
        {
           subnet_name = "dev-microservices-new-gke-cluster-subnets"
           subnet_ip   = "10.40.0.0/16"
           subnet_region = "us-east4"
           subnet_private_access = true
           subnet_flow_logs      = "false"
           description           = "Subnets for running GKE Private cluster"
        }
    ]
    ## These secondary subnets are mandatory if we would want to launch GKE cluster in VPC Native Cluster. 
    ## Ref: https://jayendrapatil.com/google-kubernetes-engine-networking/
    secondary_ranges = {
        dev-microservices-new-gke-cluster-subnets = [
           {
              range_name    = "dev-microservices-new-cluster-pod-subnet"
              ip_cidr_range = "10.1.0.0/16"
           },
           {
              range_name    = "dev-microservices-new-cluster-service-subnet"
              ip_cidr_range = "10.2.0.0/16"
           }
        ]
    }
    
    ##CloudNat & Router Info
    router_description = "Router used by cloud nat"
    router_name = "dev-microservices-new-vpc-router"
    nats = [
    {
        "name": "dev-microservices-new-vpc-nat",
        "nat_ip_allocate_option": "AUTO_ONLY",
        "source_subnetwork_ip_ranges_to_nat": "LIST_OF_SUBNETWORKS",
        "subnetworks": [
        {
            "name": "dev-microservices-new-private-subnets",
            "source_ip_ranges_to_nat": ["ALL_IP_RANGES"] ##List of options for which source IPs in the subnetwork should have NAT enabled.
        },
        {
            "name": "dev-microservices-new-database-subnets",
            "source_ip_ranges_to_nat": ["ALL_IP_RANGES"] ##List of options for which source IPs in the subnetwork should have NAT enabled.
        },
        {
            "name": "dev-microservices-new-gke-cluster-subnets",
            "source_ip_ranges_to_nat": ["ALL_IP_RANGES"] ##List of options for which source IPs in the subnetwork should have NAT enabled.
        }]
    }]
}

module "kubernetes_engine" {
    source = "./modules/gcp/gke"
    project_id = "playground-351903"
    region = "us-east4"
    network_name = "dev-microservices-vpc"
    cluster_name = "dev-cluster"
    description = "cluster for running containerized application that makes up the application"
    cluster_node_zones = ["us-east4-a", "us-east4-b", "us-east4-c"]
    cluster_node_subnet_name = "subnet02"
    cluster_pods_subnet_name = "cluster-pod-subnet"
    cluster_service_subnet_name = "cluster-service-subnet"
    http_load_balancing = true
    initial_node_count = 1
    node_pools = [
        {
          name                      = "applications"
          machine_type              = "e2-medium"
          node_locations            = "us-east4-a,us-east4-b,us-east4-c"
          autoscaling               = true
          min_count                 = 1
          max_count                 = 10
          local_ssd_count           = 0
          disk_size_gb              = 100
          disk_type                 = "pd-standard"
          image_type                = "COS_CONTAINERD"
          enable_gcfs               = false
          auto_repair               = true
          auto_upgrade              = true
          preemptible               = false
        }
    ]
}

# module "bastion_host" {
#     source = "./modules/gcp/bastion"
#     project_id = "playground-351903"
#     region = "us-east4"
#     image_family = "ubuntu-1804-lts"
#     image_project = "ubuntu-os-cloud"
#     bastion_host_name = "eks-cluster-bastion"
#     tags = ["eks-devcluster-bastion"]
#     labels = {
#         "env": "dev",
#         "type": "bastion"
#     }
#     machine_type = "e2-medium"
#     disk_size_gb = 20
#     disk_type = "pd-balanced"
#     network = module.vpc.network_self_link
#     subnet = "https://www.googleapis.com/compute/v1/projects/playground-351903/regions/us-east4/subnetworks/dev-microservices-new-private-subnets"
#     members = ["user:prashant@argonaut.dev", "user:surya@argonaut.dev"]
#     fw_name_allow_ssh_from_iap = "allow-ssh-rule-from-iap" ##
#     service_account_name = "eks-devcluster-bastion"
# }

output "subnet_self_links" {
    value = module.vpc.subnets_self_links
}

output "vpc_self_links" {
    value = module.vpc.network_self_link
}