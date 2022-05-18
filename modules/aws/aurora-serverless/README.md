#Aurora-serverless supports the following db engines. The module is for deploying rds serverless dbcluster
```
aurora-mysql
aurora-postgresql
```

IMP Points:
```
Any time if you would want to test locally ( meaning deploying cluster resources ), then checkout to examples folder for terraform.tfvars in it's respective engine folder and move to root level
for ex: 
cp examples/aurora-mysql/terraform.tfvars .
```


## issues should occur when we specify following values
```
Don't pass multiple subnets from with in the same availabilityZone
Error: doesn't support DB subnet groups with subnets in the same Availability Zone. Choose a DB subnet group with subnets in different Availability Zones.
```