# module "mariadb" {
#   source       = "./modules/aws/rds"
#   engine       = "mariadb"
#   identifier   = "mariadb-test"
#   aws_region   = "ap-south-1"
#   vpc          = {
#     name = "prmysqlenv"
#     vpc_id = "vpc-03ef38c6bc6095c45"
#     public_subnets = ["subnet-09665f45a62377279", "subnet-0d68da8317f0f5768", "subnet-027621393dd2dc918"]
#     private_subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
#     database_subnets = ["subnet-0af91ed21e175340c", "subnet-00da575fa010bf99c", "subnet-03cd3c8b9f874b91e"]
#     default_security_group_id = "sg-09a9a80fbeed7300f"
#     vpc_cidr_block = "10.0.0.0/16"
#   }
#   create_db_subnet_group = false
#   skip_final_snapshot = true
#   db_subnet_group_name = "prmysqlenv"
#   default_tags = {
#     "argonaut.dev/name"        = "mariadb-test"
#     "argonaut.dev/type"        = "RDS"
#     "argonaut.dev/manager"     = "argonaut.dev"
#     "argonaut.dev/rds-engine"  = "ap-south-1"
#     "argonaut.dev/env/dev" = "true"
#   }
#   visibility = "public"
#   name = "testdb"
#   monitoring_interval = 60
#   create_monitoring_role = true
#   monitoring_role_name = "mariadb-test-monitoring-role"
#   enabled_cloudwatch_logs_exports = ["audit", "general", "error", "slowquery"]
#   major_engine_version = "10.3"
#   performance_insights_enabled = false
#   parameters = [
#     {
#       "name": "slow_query_log",
#       "value": "true"
#     },
#     {
#       "name": "general_log",
#       "value": "true"
#     },
#     {
#       "name": "log_output",
#       "value": "FILE"
#     }
#   ]
#   options = [
#     {
#       option_name = "MARIADB_AUDIT_PLUGIN"
#     }
#   ]
#   engine_version = "10.3.35"
#   family = "mariadb10.3"
#   instance_class = "db.t3.micro"
#   storage = 40
#   max_allocated_storage = 1000
#   username = "pavan"
#   password = "argoadmin123#"
# }

# module "mysql" {
#   source       = "./modules/aws/rds"
#   engine       = "mysql"
#   identifier   = "mysql-test"
#   aws_region   = "ap-south-1"
#   vpc          = {
#     name = "prmysqlenv"
#     vpc_id = "vpc-03ef38c6bc6095c45"
#     public_subnets = ["subnet-09665f45a62377279", "subnet-0d68da8317f0f5768", "subnet-027621393dd2dc918"]
#     private_subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
#     database_subnets = ["subnet-0af91ed21e175340c", "subnet-00da575fa010bf99c", "subnet-03cd3c8b9f874b91e"]
#     default_security_group_id = "sg-09a9a80fbeed7300f"
#     vpc_cidr_block = "10.0.0.0/16"
#   }
#   create_db_subnet_group = false
#   skip_final_snapshot = false
#   db_subnet_group_name = "prmysqlenv"
#   default_tags = {
#     "argonaut.dev/name"        = "mysql-test"
#     "argonaut.dev/type"        = "RDS"
#     "argonaut.dev/manager"     = "argonaut.dev"
#     "argonaut.dev/rds-engine"  = "ap-south-1"
#     "argonaut.dev/env/dev" = "true"
#   }
#   visibility = "public"
#   name = "testdb"
#   monitoring_interval = 60
#   create_monitoring_role = true
#   monitoring_role_name = "mysql-test-monitoring-role"
#   enabled_cloudwatch_logs_exports = ["audit", "general", "error", "slowquery"]
#   major_engine_version = "8.0"
#   performance_insights_enabled = false
#   parameters = [
#     {
#       "name": "slow_query_log",
#       "value": "1"
#     },
#     {
#       "name": "general_log",
#       "value": "1"
#     },
#     {
#       "name": "log_output",
#       "value": "FILE"
#     }
#   ]
#   options = [
#     {
#       option_name = "MARIADB_AUDIT_PLUGIN"
#     }
#   ]
#   engine_version = "8.0.27"
#   family = "mysql8.0"
#   instance_class = "db.t3.micro"
#   storage = 40
#   max_allocated_storage = 1000
#   username = "pavan"
#   password = "argoadmin123#"
# }

# module "cloudfront-s3" {
#   source = "../tf-modules/modules/aws/cloudfront-s3/"
#   default_tags = {
#     "argonaut.dev/name" = "test-app"
#     "argonaut.dev/manager" = "argonaut.dev"
#     "argonaut.dev/type" = "Cloudfront with S3"
#     "argonaut.dev/env/pentest" = "true"
#   }
#   aws_region = "ap-south-1"
#   app_name = "test-app"
#   create_origin_access_identity = true
#   ##S3Origin
#   description = "cloudfront with s3 as origin"
#   /* CF with existing bucket */
#   #cf_origin_create_bucket = false
#   #cf_origin_bucket_name = "S3_REGION_BUCKET_NAME"
#   #attach_policy = false
#   /* CF With New Bucket */
#   cf_origin_create_bucket = true
#   cf_origin_bucket_name = "test-origin-argonaut-dev-123"
#   attach_policy = false
  
#   default_root_object = "index.html"
#   ##CF Logging
#   logging = true
#   ##CF With custom domain
#   domain_name = "app.bazzarapp.in"
#   subdomain = "dev"
# }

# module "cloudfront-custom-origin" {
#   source = "../tf-modules/modules/aws/cloudfront-custom-origin/"
#   default_tags = {
#     "argonaut.dev/name" = "test-app"
#     "argonaut.dev/manager" = "argonaut.dev"
#     "argonaut.dev/type" = "Cloudfront with S3"
#     "argonaut.dev/env/pentest" = "true"
#   }
#   aws_region = "ap-south-1"
#   app_name = "test-app"
#   ##S3Origin
#   description = "cloudfront with custom dns as origin"
#   /* CF with existing bucket */
#   #cf_origin_create_bucket = false
#   #cf_origin_bucket_name = "S3_REGION_BUCKET_NAME"
#   #attach_policy = false
#   /* CF With New Bucket */
#   custom_origin_dns_name = "ad8991c92a90c461ead5248543390920-b4c886d3bbcecd5e.elb.ap-south-1.amazonaws.com"
#   ##CF Logging
#   logging = true
#   ##CF With custom domain
#   domain_name = "app.bazzarapp.in"
#   subdomain = "dev"
# }


# module "aurora-serverless" {
#   source = "./modules/aws/aurora_serverless/"
#   cluster_name = "serverless-v1-testing"
#   cluster_engine = "aurora-mysql"
#   database_name = "testdb"
#   master_username = "argonaut"
#   master_password = "argonautadmin123#"
#   db_subnet_group_name = "serverless-v1-testing-subnet-group"
#   aws_region = "ap-south-1"
#   //As we know enabling logs to cloudwatch requires custom parameter group. Hence, creating one
#   create_db_cluster_parameter_group = true
#   db_cluster_parameter_group_family = "aurora-mysql5.7"
#   enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
#   db_cluster_parameter_group_parameters = [
#     {
#       "name": "general_log",
#       "value": "1"
#     },
#     {
#       "name": "slow_query_log",
#       "value": "1"
#     },
#     {
#       "name": "server_audit_logging",
#       "value": "1"
#     },
#     {
#       "name": "server_audit_logs_upload",
#       "value": "1"
#     }
#   ]
#   skip_final_snapshot = true
#   cluster_min_capacity = 2
#   cluster_max_capacity = 16
#   vpc          = {
#     name = "prmysqlenv"
#     vpc_id = "vpc-03ef38c6bc6095c45"
#     public_subnets = ["subnet-09665f45a62377279", "subnet-0d68da8317f0f5768", "subnet-027621393dd2dc918"]
#     private_subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
#     database_subnets = ["subnet-0af91ed21e175340c", "subnet-00da575fa010bf99c", "subnet-03cd3c8b9f874b91e"]
#     default_security_group_id = "sg-09a9a80fbeed7300f"
#     vpc_cidr_block = "10.0.0.0/16"
#   }
#     default_tags = {
#     "argonaut.dev/name" = "test-app"
#     "argonaut.dev/manager" = "argonaut.dev"
#     "argonaut.dev/type" = "Aurora mysql"
#     "argonaut.dev/env/pentest" = "true"
#   }
# }

# module "aurora-serverless-postgres" {
#   source = "./modules/aws/aurora_serverless/"
#   cluster_name = "serverless-v1-postgres-testing"
#   cluster_engine = "aurora-postgresql"
#   database_name = "testdb"
#   master_username = "argonaut"
#   master_password = "argonautadmin123#"
#   db_subnet_group_name = "serverless-v1-postgres-testing-subnet-group"
#   aws_region = "ap-south-1"
#   //As we know enabling logs to cloudwatch requires custom parameter group. Hence, creating one
#   create_db_cluster_parameter_group = true
#   db_cluster_parameter_group_family = "aurora-postgresql10"
#   enabled_cloudwatch_logs_exports = ["audit", "error", "general", "postgres"]
#   skip_final_snapshot = true
#   cluster_min_capacity = 2
#   cluster_max_capacity = 16
#   vpc          = {
#     name = "prmysqlenv"
#     vpc_id = "vpc-03ef38c6bc6095c45"
#     public_subnets = ["subnet-09665f45a62377279", "subnet-0d68da8317f0f5768", "subnet-027621393dd2dc918"]
#     private_subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
#     database_subnets = ["subnet-0af91ed21e175340c", "subnet-00da575fa010bf99c", "subnet-03cd3c8b9f874b91e"]
#     default_security_group_id = "sg-09a9a80fbeed7300f"
#     vpc_cidr_block = "10.0.0.0/16"
#   }
#     default_tags = {
#     "argonaut.dev/name" = "test-app"
#     "argonaut.dev/manager" = "argonaut.dev"
#     "argonaut.dev/type" = "Aurora mysql"
#     "argonaut.dev/env/pentest" = "true"
#   }
# }


# module "msk_cluster" {
#   source = "./modules/aws/msk"
#   name = "msk-cluster-sg"
#   default_tags = {
#     "argonaut.dev/name" = "test-app"
#     "argonaut.dev/manager" = "argonaut.dev"
#     "argonaut.dev/type" = "msk-cluster-with-vpc"
#     "argonaut.dev/env/pentest" = "true"
#   }
#   aws_region = "ap-south-1"
#   broker_volume_size = 100
#   visibility = "private"
#   cluster_public_access = "DISABLED"
#   #cluster_public_access = "SERVICE_PROVIDED_EIPS"
#   kafka_version = "2.6.2"
#   client_sasl_iam_enabled = false
#   # properties = {
#   #   "security.protocol": "SASL_SSL",
#   #   "sasl.mechanism": "AWS_MSK_IAM",
#   #   "sasl.jaas.config": "software.amazon.msk.auth.iam.IAMLoginModule required;"
#   #   "sasl.client.callback.handler.class": "software.amazon.msk.auth.iam.IAMClientCallbackHandler"
#   # }
#   storage_autoscaling_max_capacity = 1000
#   vpc          = {
#     name = "prmysqlenv"
#     vpc_id = "vpc-03ef38c6bc6095c45"
#     public_subnets = ["subnet-09665f45a62377279", "subnet-0d68da8317f0f5768", "subnet-027621393dd2dc918"]
#     private_subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
#     database_subnets = ["subnet-0af91ed21e175340c", "subnet-00da575fa010bf99c", "subnet-03cd3c8b9f874b91e"]
#     default_security_group_id = "sg-09a9a80fbeed7300f"
#     vpc_cidr_block = "10.0.0.0/16"
#   }
# }
locals {
  # Automatically load environment-level variables

  env = "testing"

  region = "ap-south-1"
}

# module "eks" {
#   source = "./modules/aws/eks"
#   default_tags = {
#     "argonaut.dev/name" = "secondcluster"
#     "argonaut.dev/manager" = "argonaut.dev"
#     "argonaut.dev/type" = "EKS Cluster"
#     "argonaut.dev/env/${local.env}" = "true"
#   }

#   spot_tags = {
#     "k8s.io/cluster-autoscaler/node-template/label/lifecycle": "Ec2Spot"
#     "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot": "true"
#     "k8s.io/cluster-autoscaler/node-template/label/gpu-count": "0"
#     "k8s.io/cluster-autoscaler/node-template/taint/spotInstance": "true:PreferNoSchedule"
#     "k8s.io/cluster-autoscaler/enabled": "true"
#   }

#   on_demand_tags = {
#     # EC2 tags required for cluster-autoscaler auto-discovery
#     "k8s.io/cluster-autoscaler/node-template/label/lifecycle": "OnDemand"
#     "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot": "false"
#     "k8s.io/cluster-autoscaler/node-template/label/gpu-count": "0"
#     "k8s.io/cluster-autoscaler/enabled": "true"
#   }

#   # ami_type = "AL2_x86_64"

#   env = "${local.env}"
#   vpc = {
#     name    = "${local.env}"
#     id      = "vpc-03ef38c6bc6095c45"
#     subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
#   }

#   cluster = {
#     name = "multi-nodegroup-testing"
#     version = "1.21" # "{ {.Spec.PlatformVersion} }" TODO: add platform version
#   }

#   k8s_service_account_name = "multi-nodegroup-testing-argonaut-sa"

#   node_groups = [
#     {
#       # name_prefix = "firstcluster"
#       ng_name = "ng-one"
#       ami_type = "AL2_x86_64"
#       desired_capacity = 2
#       max_capacity = 2
#       min_capacity = 1
#       disk_size = 50
#       instance_type = "t3.small"
#       #capacity_type = "SPOT"
#       spot = false
#       k8s_labels = {}
#       taints = []
#     },
#     {
#       # name_prefix = "secondcluster"
#       ng_name = "ng-two"
#       desired_capacity = 2
#       ami_type = "AL2_x86_64"
#       max_capacity = 2
#       min_capacity = 1
#       disk_size = 50
#       instance_type = "t3.medium"
#       spot = true
#       k8s_labels = {
#         "type": "observability"
#       }
#       taints = []
#     }
#   ]

#   aws_region = "${local.region}"
# }

module "eks" {
  source = "./modules/aws/eks"
  default_tags = {
    "argonaut.dev/name" = "secondcluster"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "EKS Cluster"
    "argonaut.dev/env/${local.env}" = "true"
  }

  spot_tags = {
    "k8s.io/cluster-autoscaler/node-template/label/lifecycle": "Ec2Spot"
    "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot": "true"
    "k8s.io/cluster-autoscaler/node-template/label/gpu-count": "0"
    "k8s.io/cluster-autoscaler/node-template/taint/spotInstance": "true:PreferNoSchedule"
    "k8s.io/cluster-autoscaler/enabled": "true"
  }

  on_demand_tags = {
    # EC2 tags required for cluster-autoscaler auto-discovery
    "k8s.io/cluster-autoscaler/node-template/label/lifecycle": "OnDemand"
    "k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot": "false"
    "k8s.io/cluster-autoscaler/node-template/label/gpu-count": "0"
    "k8s.io/cluster-autoscaler/enabled": "true"
  }

  # ami_type = "AL2_x86_64"

  env = "${local.env}"
  vpc = {
    name    = "${local.env}"
    id      = "vpc-03ef38c6bc6095c45"
    subnets = ["subnet-00e2c4935318f4280", "subnet-0d28ea8521dfe3859", "subnet-02b8b817473097c04"]
  }

  cluster = {
    name = "multi-nodegroup-testing"
    version = "1.21" # "{ {.Spec.PlatformVersion} }" TODO: add platform version
  }

  k8s_service_account_name = "multi-nodegroup-testing-argonaut-sa"
  
  ami_type = "AL2_x86_64"

  node_group = {
    name_prefix = "dev"
    desired_capacity = 3
    max_capacity = 6
    min_capacity = 3
    disk_size = 40
    instance_type = "t3.medium"
    spot = true
  }
  
  map_users = []
  map_accounts = []
  map_roles = []
  
  aws_region = "${local.region}"
}