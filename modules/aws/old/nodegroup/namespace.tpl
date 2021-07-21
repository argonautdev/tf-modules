data "aws_eks_cluster_auth" "{{.ClusterName}}" {
  name = "{{.ClusterName}}"
}

provider "kubernetes" {
    host = data.terraform_remote_state.cluster.outputs.endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.certificate)
    token                  = data.aws_eks_cluster_auth.{{.ClusterName}}.token
}

resource "kubernetes_namespace" "{{.Namespace}}-{{.UID}}" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }

    name = "{{.Namespace}}"
  }
}