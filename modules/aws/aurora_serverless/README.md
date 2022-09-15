#Aurora-serverless supports the following db engines. The module is for deploying rds serverless dbcluster
```
aurora-mysql
aurora-postgresql
```

https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v1.how-it-works.html#aurora-serverless.architecture


```
If we specify 
   engine = aurora , then cluster instance creates with aurora5.6
   engine = aurora-mysql, then cluster instance creates with aurora-mysql5.7
   engine = aurora-postgresql,  then cluster instance creates with aurora-postgresql10.12 ( or later)
```

IMP Points:
```
Any time if you would want to test locally ( meaning deploying cluster resources ), then checkout to examples folder for terraform.defaults in it's respective engine folder and move to root level
for ex: 
cp examples/aurora-mysql/terraform.defaults terraform.tfvars
```


## issues should occur when we specify following values
```
Don't pass multiple subnets from with in the same availabilityZone
Error: doesn't support DB subnet groups with subnets in the same Availability Zone. Choose a DB subnet group with subnets in different Availability Zones.
```

##IMP Points:
```
For aurora serverless these feature not present
   1. No Maintaince window
   2. No Backup Window
   3. No Backtrack window
   4. No Option for Public access or Not
   5. No DB Instancelevel Parametergroup 
   6. No Autoscaling ( Ref: https://blog.searce.com/amazon-aurora-serverless-features-limitations-glitches-d07f0374a2ab )
   7. Aurora Cluster level Parameters ( https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Reference.ParameterGroups.html )
   
   #8. Aurora serverless ( postgresql ) currently doesn't support cloudwatch logs exports
   9. No Enhanced Monitoring
   10. Aurora Serverless currently doesn't support IAM Authentication. 
   
   ```
   for postgresql 
   ╷
    │ Error: error modifying DB Cluster Parameter Group: InvalidParameterValue: Could not find parameter with name: slow_query_log
    │       status code: 400, request id: 4e36d8b3-4085-4def-877a-175a9d4ee5da
    │ 
    │   with module.aurora-serverless-postgres.module.aurora_cluster.aws_rds_cluster_parameter_group.this[0],
    │   on .terraform/modules/aurora-serverless-postgres.aurora_cluster/main.tf line 382, in resource "aws_rds_cluster_parameter_group" "this":
    │  382: resource "aws_rds_cluster_parameter_group" "this" {
    │ 
    ╵
```
   
   ```
   Error: error creating RDS cluster: InvalidParameterCombination: Aurora Serverless currently doesn't support CloudWatch Log Export.
│       status code: 400, request id: 022ffe58-aa9e-4f5d-9928-bf2ffc87c56c
│ 
│   with module.aurora_cluster.aws_rds_cluster.this[0],
│   on .terraform/modules/aurora_cluster/main.tf line 47, in resource "aws_rds_cluster" "this":
│   47: resource "aws_rds_cluster" "this" {
   ```
│ 
```

##ParameterGroups
```
  1. When creating Parametergroups to list all of the available parameter group families, use the following command:
  postgresql:
  aws rds describe-db-engine-versions --engine aurora-postgresql --filters "Name=engine-mode,Values=serverless" --query "DBEngineVersions[].DBParameterGroupFamily" --region <REGION> --output text
  mysql:
  aws rds describe-db-engine-versions --engine aurora-mysql --filters "Name=engine-mode,Values=serverless" --query "DBEngineVersions[].DBParameterGroupFamily" --region <REGION> --output text
```  

##On which conditions aurora scalesin & out..The vaules are set by aws not us.
```
Ref: https://blog.searce.com/amazon-aurora-serverless-features-limitations-glitches-d07f0374a2ab
Scale Up: scale-up is 3 minutes since the last scaling operation
CPU > 70%
Connections > 90%
Scale Down: scale-down is 15 minutes since the last scaling operation
CPU < 30%
Connections < 40%

```