##Command to find db-engine-versions
```
  For available Parameters: https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html
  Command: aws rds describe-db-engine-versions --engine <ENGINE> --region <REGION> --query 'DBEngineVersions[].EngineVersion' --output text
  Example:
        aws rds describe-db-engine-versions --engine mariadb --region ap-south-1 --query 'DBEngineVersions[].EngineVersion' --output text
```

##Listing the DB instance classes that are supported by a specific DB engine version in an AWS Region

To list the DB instance classes that are supported by a specific DB engine version in an AWS Region, run the following command.

```
aws rds describe-orderable-db-instance-options --engine <engine> --engine-version <version> \
    --query "OrderableDBInstanceOptions[].{DBInstanceClass:DBInstanceClass,SupportedEngineModes:SupportedEngineModes[0]}" \
    --output table \
    --region region
```

For example, the following command lists the supported DB instance classes for version 10.6.5 of the MariaDB DB engine in Mumbai.

```
aws rds describe-orderable-db-instance-options --engine mariadb --engine-version 10.6.5 \
    --query "OrderableDBInstanceOptions[].{DBInstanceClass:DBInstanceClass,SupportedEngineModes:SupportedEngineModes[0]}" \
    --output table \
    --region ap-south-1
```

##ParameterGroups
```
  1. When creating Parametergroups to list all of the available parameter group families, use the following command:
  mariadb:
  aws rds describe-db-engine-versions --engine mariadb --query "DBEngineVersions[].DBParameterGroupFamily" --region ap-south-1 --output text 
  
  Ref: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MariaDB.Parameters.html
  Refer above documentation to find available parameters that can be modified. and also list of available parameters for mariadb
  
```

##OptionsGroup
```
  1. Each AWS RDS instance has its own set of options (options) that you can define using an option group.
  2. By default, AWS RDS creates a default option group when you created your RDS instance.
  3. Not all RDS instance type supports option group, for instance PostgreSQL does not support an option group.
  
  Run the following command to find list of options available for engine in specific region. The command returns only options that can be modifiable.
  
  aws rds describe-option-group-options --engine-name mariadb --major-engine-version 10.6 --region ap-south-1 --query 'OptionGroupOptions[].OptionGroupOptionSettings[?IsModifiable==`true`]' --output table
```
