#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EKS Cluster
#  * EKS Storage class
#

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
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "{{.Name}}-AmazonEKSClusterPolicy-{{.UID}}" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.{{.Name}}-{{.UID}}.name
}

resource "aws_iam_role_policy_attachment" "{{.Name}}-AmazonEKSVPCResourceController-{{.UID}}" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.{{.Name}}-{{.UID}}.name
}

resource "aws_security_group" "{{.Name}}-{{.UID}}" {
  name        = "{{.Name}}-{{.UID}}"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.terraform_remote_state.environment.outputs.vpc

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = var.cluster_name
    ManagedBy = "argonaut.dev"
  }
}

resource "aws_security_group_rule" "{{.Name}}-{{.UID}}-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.{{.Name}}-{{.UID}}.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "{{.Name}}-{{.UID}}" {
  name     = var.cluster_name
  role_arn = aws_iam_role.{{.Name}}-{{.UID}}.arn
  version = var.platform_version
  vpc_config {
    subnet_ids         = data.terraform_remote_state.environment.outputs.subnet_id
    security_group_ids         = [aws_security_group.{{.Name}}-{{.UID}}.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.{{.Name}}-AmazonEKSClusterPolicy-{{.UID}},
    aws_iam_role_policy_attachment.{{.Name}}-AmazonEKSVPCResourceController-{{.UID}},
  ]
}


resource "kubernetes_storage_class" "{{.Name}}-{{.UID}}" {
  metadata {
    name = "default-storageclass"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = true
    }
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp2"
  }
  mount_options = ["file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}

