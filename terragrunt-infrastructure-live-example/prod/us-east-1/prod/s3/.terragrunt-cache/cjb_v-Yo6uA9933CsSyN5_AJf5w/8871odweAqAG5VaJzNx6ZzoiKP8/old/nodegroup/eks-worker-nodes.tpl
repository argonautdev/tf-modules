#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

data "terraform_remote_state" "cluster" {
  backend = "pg"
  config = {
    conn_str = "postgres://{{.Backend.Username}}:{{.Backend.Password}}@{{.Backend.Host}}/tf?search_path=tf_{{.OrgID}}_{{.ClusterUID}}"
  }
}

data "terraform_remote_state" "environment" {
  backend = "pg"
  config = {
    conn_str = "postgres://{{.Backend.Username}}:{{.Backend.Password}}@{{.Backend.Host}}/tf?search_path=tf_{{.OrgID}}_{{.EnvironmentUID}}"
  }
}

resource "aws_iam_role" "{{.Name}}-{{.UID}}" {
  name = "{{.Name}}-{{.UID}}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "{{.Name}}-AmazonEKSWorkerNodePolicy-{{.UID}}" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.{{.Name}}-{{.UID}}.name
}

resource "aws_iam_role_policy_attachment" "{{.Name}}-AmazonEKS_CNI_Policy-{{.UID}}" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.{{.Name}}-{{.UID}}.name
}

resource "aws_iam_role_policy_attachment" "{{.Name}}-AmazonEC2ContainerRegistryReadOnly-{{.UID}}" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.{{.Name}}-{{.UID}}.name
}

resource "aws_security_group" "{{.Name}}-{{.UID}}" {
  name        = "{{.Name}}-{{.UID}}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = data.terraform_remote_state.environment.outputs.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "{{.Name}}"
    "kubernetes.io/cluster/${data.terraform_remote_state.cluster.outputs.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "{{.Name}}-{{.UID}}-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.{{.Name}}-{{.UID}}.id
  source_security_group_id = data.terraform_remote_state.cluster.outputs.security_group_id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "{{.Name}}-{{.UID}}-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.{{.Name}}-{{.UID}}.id
  source_security_group_id = data.terraform_remote_state.cluster.outputs.security_group_id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "{{.Name}}-{{.UID}}-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.{{.Name}}-{{.UID}}.id
  source_security_group_id = data.terraform_remote_state.cluster.outputs.security_group_id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_eks_node_group" "{{.Name}}-{{.UID}}" {
  cluster_name    = data.terraform_remote_state.cluster.outputs.cluster_name
  node_group_name = "{{.Name}}"
  node_role_arn   = aws_iam_role.{{.Name}}-{{.UID}}.arn
  subnet_ids      = data.terraform_remote_state.environment.outputs.subnet_id
  capacity_type   = var.capacity
  disk_size       = var.disk
  instance_types  = [var.instance]

  scaling_config {
    desired_size = var.desired
    max_size     = var.max
    min_size     = var.min
  }

  depends_on = [
    aws_iam_role_policy_attachment.{{.Name}}-AmazonEKSWorkerNodePolicy-{{.UID}},
    aws_iam_role_policy_attachment.{{.Name}}-AmazonEKS_CNI_Policy-{{.UID}},
    aws_iam_role_policy_attachment.{{.Name}}-AmazonEC2ContainerRegistryReadOnly-{{.UID}},
  ]

  {{ if .IsSpot }}
 tags = {
      "argonaut.dev/environment" = "{{.Name}}"
      "k8s.io/cluster-autoscaler/node-template/label/lifecycle" = "Ec2Spot"
      "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot" = "true"
      "k8s.io/cluster-autoscaler/node-template/label/gpu-count" = "0"
      "k8s.io/cluster-autoscaler/node-template/taint/spotInstance" = "true:PreferNoSchedule"
      "k8s.io/cluster-autoscaler/enabled" = "true"
      "kubernetes.io/cluster/${data.terraform_remote_state.cluster.outputs.cluster_name}" = "owned"
      "eks/nodegroup-type" = "managed"
  }

  labels = {
      "argonaut.dev/environment" = "{{.Name}}"
      "lifecycle" = "Ec2Spot"
      "aws.amazon.com/spot" = "true"
  }

{{else}}
  tags = {
      "argonaut.dev/environment" = "{{.Name}}"
      "k8s.io/cluster-autoscaler/node-template/label/lifecycle" = var.capacity
      "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot" = "false"
      "k8s.io/cluster-autoscaler/node-template/label/gpu-count" = "0"
      "k8s.io/cluster-autoscaler/enabled" = "true"
      "kubernetes.io/cluster/${data.terraform_remote_state.cluster.outputs.cluster_name}" = "owned"
      "eks/nodegroup-type" = "managed"
  }

  labels = {
     "argonaut.dev/environment" = "{{.Name}}"
  }
{{end}}
}
