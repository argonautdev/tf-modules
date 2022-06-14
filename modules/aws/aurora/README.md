##Aurora-Provisioned supports the following instancetypes. The module is for deploying rds provisioned database with either memory-optimized instance classes or burstable-performance instance classes
```
1. Serverless it's always (db.serverless)
2. MemoryOptimized
3. Brustable (General Purpose)
```

###Command to see list of available versions for engine "aurora-mysql or aurora-postgres"
##Available engines 
  1. aurora-mysql
  2. aurora-postgresql

```
aws rds --region <REGION> describe-db-engine-versions --engine <ENGINE> \
    --filters "Name=status, Values=available" \
    --query "DBEngineVersions[].EngineVersion"
```

for example, the following command lists available active versions of "aurora-mysql" engine
```
aws rds --region us-east-1 describe-db-engine-versions --engine aurora-mysql \
      --filters "Name=status, Values=available" \
      --query "DBEngineVersions[].EngineVersion"
```

for example, the following command lists available active versions of "aurora-postgresql" engine
```
aws rds --region us-east-1 describe-db-engine-versions --engine aurora-postgresql \
      --filters "Name=status, Values=available" \
      --query "DBEngineVersions[].EngineVersion"
```

##Listing the DB instance classes that are supported by a specific DB engine version in an AWS Region

To list the DB instance classes that are supported by a specific DB engine version in an AWS Region, run the following command.

```
aws rds describe-orderable-db-instance-options --engine <engine> --engine-version <version> \
    --query "OrderableDBInstanceOptions[].{DBInstanceClass:DBInstanceClass,SupportedEngineModes:SupportedEngineModes[0]}" \
    --output table \
    --region region
```

For example, the following command lists the supported DB instance classes for version 12.4 of the Aurora PostgreSQL DB engine in US East (N. Virginia).

```
aws rds describe-orderable-db-instance-options --engine aurora-postgresql --engine-version 12.4 \
    --query "OrderableDBInstanceOptions[].{DBInstanceClass:DBInstanceClass,SupportedEngineModes:SupportedEngineModes[0]}" \
    --output table \
    --region us-east-1
```

For example, the following command lists the supported DB instance classes for version 5.7.mysql_aurora.2.04.2 of the Aurora Mysql DB engine in US East (N. Virginia).

```
aws rds describe-orderable-db-instance-options --engine aurora-mysql --engine-version 5.7.mysql_aurora.2.04.2 \
    --query "OrderableDBInstanceOptions[].{DBInstanceClass:DBInstanceClass,SupportedEngineModes:SupportedEngineModes[0]}" \
    --output table \
    --region us-east-1
```

IMP Links:
```
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.SupportAurora ( DB InstanceClasses )
```

IMP Points:
```
Any time if you would want to test locally ( meaning deploying cluster resources ), then checkout to examples folder for terraform.defaults in it's respective engine folder and move to root level
for ex: 
cp examples/aurora-mysql/terraform.defaults terraform.tfvars
```


## issues should occur when we specify following values
```
Don't specify master_username as "admin", seems reserved word.
Error: error creating RDS cluster: InvalidParameterValue: MasterUsername admin cannot be used as it is a reserved word used by the engine
│       status code: 400, request id: e93e0de2-935e-4eaa-b223-734dd05dc579

Don't pass multiple subnets from with in the same availabilityZone
Error: doesn't support DB subnet groups with subnets in the same Availability Zone. Choose a DB subnet group with subnets in different Availability Zones.
```


## Aurora Scaling: 
```
  Ref: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Integrating.AutoScaling.html
  1. Although Aurora autoscaling manages the replicas you must first create an Aurora DB cluster with a primary instance and at least one Aurora Replica
  2. When Aurora Auto Scaling adds a new Aurora Replica, the new Aurora Replica is the same DB instance class as the one used by the primary instance
```

## RDS Enhanced Monitoring
```
  Ref: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.overview.html
  1. CloudWatch gathers metrics about CPU utilization from the hypervisor for a DB instance. In contrast, Enhanced Monitoring gathers its metrics from an agent on the DB instance.
  2. Enhanced Monitoring metrics are stored in the CloudWatch Logs instead of in CloudWatch metrics.
  3. By default, Enhanced Monitoring metrics are stored for 30 days in the CloudWatch Logs.
```



