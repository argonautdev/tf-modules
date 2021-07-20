#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.{{.Name}}-{{.UID}}.arn}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.{{.Name}}-{{.UID}}.endpoint}
    certificate-authority-data: ${aws_eks_cluster.{{.Name}}-{{.UID}}.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}

output "cluster_name" {
  value = aws_eks_cluster.{{.Name}}-{{.UID}}.name
}

output "endpoint" {
  value = aws_eks_cluster.{{.Name}}-{{.UID}}.endpoint
}

output "certificate" {
  value = aws_eks_cluster.{{.Name}}-{{.UID}}.certificate_authority[0].data
}

output security_group_id {
  value = aws_security_group.{{.Name}}-{{.UID}}.id
}