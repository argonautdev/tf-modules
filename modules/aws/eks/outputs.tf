output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "node_groups" {
  description = "Outputs from node groups"
  value       = module.eks.node_groups
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "role_arn" {
  value = module.iam_assumable_role_admin.this_iam_role_arn
}

output "service_account_name" {
  value = var.k8s_service_account_name
}

output "certificate_authority_data" {
  value = data.aws_eks_cluster.cluster.certificate_authority.0.data
}
