##Command to find db-engine-versions
```
  For available Parameters: https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html
  Command: aws rds describe-db-engine-versions --engine <ENGINE> --region <REGION> --query 'DBEngineVersions[].EngineVersion' --output text
  Example:
        aws rds describe-db-engine-versions --engine mariadb --region ap-south-1 --query 'DBEngineVersions[].EngineVersion' --output text
```

##Listing the DB instance classes that are supported by a specific DB engine version in an AWS Regions

```
The following command outputs the following
1. Supported instancetypes based on StorageClass
2. Whether Instancetype supports StorageScaling or not
3. Supported AvailabilityZones in a region
```

```
aws rds describe-orderable-db-instance-options --engine engine --engine-version version \
    --query "*[].{DBInstanceClass:DBInstanceClass, AvailabilityZones:AvailabilityZones, AutoScaling:SupportsStorageAutoscaling, StorageType:StorageType}|[?StorageType=='gp2']|[].{DBInstanceClass:DBInstanceClass}" \
    --output text \
    --region region
```

##ParameterGroups
```
  1. When creating Parametergroups to list all of the available parameter group families, use the following command:
  mariadb:
  aws rds describe-db-engine-versions --engine mariadb --query "DBEngineVersions[].DBParameterGroupFamily" --region ap-south-1 --output text 
  
  Ref: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MariaDB.Parameters.html
  Refer above documentation to find available parameters that can be modified. and also list of available parameters for mariadb
  run the following command to list all available parameters for family
  
  aws rds describe-engine-default-parameters --db-parameter-group-family FAMILY --region REGION --output json --query 'EngineDefaults.Parameters[?IsModifiable==`true`]'
  
  command:
  aws rds describe-engine-default-parameters --db-parameter-group-family mariadb10.3 --region ap-south-1 --output json --query 'EngineDefaults.Parameters[?IsModifiable==`true`]'
```

##OptionsGroup
```
  1. Each AWS RDS instance has its own set of options (options) that you can define using an option group.
  2. By default, AWS RDS creates a default option group when you created your RDS instance.
  3. Not all RDS instance type supports option group, for instance PostgreSQL does not support an option group.
  
  Run the following command to find list of options available for engine in specific region. The command returns only options that can be modifiable.
  
  aws rds describe-option-group-options --engine-name mariadb --major-engine-version 10.6 --region ap-south-1 --query 'OptionGroupOptions[].OptionGroupOptionSettings[?IsModifiable==`true`]' --output table
```