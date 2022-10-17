package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"strings"
	"testing"
)

// var (
// 	default_tags = make(map[string]string)
// )

// An example of how to test the Terraform module in modules/aws/rds using Terratest.
func TestTerraformAwsRdsModule(t *testing.T) {
	t.Parallel()

	// Give this RDS Instance a unique ID for a name tag so we can distinguish it from any other RDS Instance running
	// in your AWS account
	// expectedName := fmt.Sprintf("terratest-aws-rds-example-%s", strings.ToLower(random.UniqueId()))
	expectedPort := int64(3306)
	db_name := "argonautdev"
	username := "argoadmin"
	password := "argoadmin123#"
	db_engine := "mariadb"
	db_engine_version := "10.3.35"
	db_instance_family := "mariadb10.3"
	db_storage := 40
	db_max_storage := 1000
	// 	default_tags{
	// 		"argonaut.dev/name":       "mariadb-test",
	// 		"argonaut.dev/type":       "RDS",
	// 		"argonaut.dev/manager":    "argonaut.dev",
	// 		"argonaut.dev/rds-engine": "ap-south-1",
	// 		"argonaut.dev/env/dev":    "true",
	// 	}
	db_instance_identifier := fmt.Sprintf("terratest-rds-instance-%s", strings.ToLower(random.UniqueId()))
	db_monitoring_role_name := fmt.Sprintf("terratest-rds-monitor-role-%s", strings.ToLower(random.UniqueId()))
	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := "ap-south-1"
	// Get Recommended InstanceType Function Takes list InstanceType That we Pass return first one which available inthe region for the engine.
	instanceType := aws.GetRecommendedRdsInstanceType(t, awsRegion, db_engine, db_engine_version, []string{"db.t3.medium", "db.t3.micro"})

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		// TerraformDir: "../modules/aws/rds",
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		// "username" and "password" should not be passed from here in a production scenario.
		Vars: map[string]interface{}{
			"engine":                 db_engine,
			"identifier":             db_instance_identifier,
			"username":               username,
			"password":               password,
			"create_db_subnet_group": false,
			"storage":                db_storage,
			"max_allocated_storage":  db_max_storage,
			"name":                   db_name,
			"engine_version":         db_engine_version,
			// 			"vpc": {
			// 				"name":                      "prmysqlenv",
			// 				"vpc_id":                    "vpc-03ef38c6bc6095c45",
			// 				"public_subnets":            "[\"subnet-09665f45a62377279\", \"subnet-0d68da8317f0f5768\", \"subnet-027621393dd2dc918\"]",
			// 				"private_subnets":           "[\"subnet-00e2c4935318f4280\", \"subnet-0d28ea8521dfe3859\", \"subnet-02b8b817473097c04\"]",
			// 				"database_subnets":          "[\"subnet-0af91ed21e175340c\", \"subnet-00da575fa010bf99c\", \"subnet-03cd3c8b9f874b91e\"]",
			// 				"default_security_group_id": "sg-09a9a80fbeed7300f",
			// 				"vpc_cidr_block":            "10.0.0.0/16",
			// 			},
			"visibility":                      "public",
			"instance_class":                  instanceType,
			"aws_region":                      awsRegion,
			"skip_final_snapshot":             true,
			"db_subnet_group_name":            "prmysqlenv",
			"enabled_cloudwatch_logs_exports": "[]",
			"create_db_parameter_group":       false,
			"create_monitoring_role":          true,
			"monitoring_role_name":            db_monitoring_role_name,
			"create_db_option_group":          false,
			"family":                          db_instance_family,
			// 			"default_tags":                    default_tags,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	dbInstanceIdentifier := terraform.Output(t, terraformOptions, "rds_instance_identifier")
	dbInstancePort := terraform.Output(t, terraformOptions, "rds_instance_port")
	dbInstanceUserName := terraform.Output(t, terraformOptions, "rds_instance_username")

	// Look up the endpoint address and port of the RDS instance
	address := aws.GetAddressOfRdsInstance(t, dbInstanceIdentifier, awsRegion)

	// Lookup parameter values. All defined values are strings in the API call response
	generalLogParameterValue := aws.GetParameterValueForParameterOfRdsInstance(t, "general_log", dbInstanceIdentifier, awsRegion)

	// Lookup option values. All defined values are strings in the API call response
	//mariadbAuditPluginServerAuditEventsOptionValue := aws.GetOptionSettingForOfRdsInstance(t, "MARIADB_AUDIT_PLUGIN", "SERVER_AUDIT_EVENTS", dbInstanceIdentifier, awsRegion)

	// Verify that the address is not null
	assert.NotNil(t, address)
	// Verify that the DB InstancePort is not null
	assert.NotNil(t, dbInstancePort)
	// Verify that the DB InstanceName is not null
	assert.NotNil(t, dbInstanceIdentifier)
	// Verify that the DB InstanceUserName is not null
	assert.NotNil(t, dbInstanceUserName)

	// Verify that the DB instance is listening on the port mentioned
	assert.Equal(t, expectedPort, dbInstancePort)
	// Booleans are (string) "0", "1"
	assert.Equal(t, "0", generalLogParameterValue)
	// assert.Equal(t, "", mariadbAuditPluginServerAuditEventsOptionValue)
	//assert.Equal(t, "CONNECT", mariadbAuditPluginServerAuditEventsOptionValue)
}
