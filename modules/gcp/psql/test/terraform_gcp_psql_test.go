package gcppsql

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	// 	"github.com/stretchr/testify/require"
	// 	"log"
	"strings"
	"testing"
)

func TestTerraformGcpPsqlModule(t *testing.T) {
	t.Parallel()

	//:= syntax is shorthand for declaring and initializing a variable, e.g. for var f project_id = "playground-351903" in this ca

	project_id := "playground-351903"
	region := "us-east4"
	db_connectivity_type := "public"
	name := fmt.Sprintf("terratest-%s-psql-instance-%s", db_connectivity_type, strings.ToLower(random.UniqueId()))
	vpc_network_name := "default"
	//Only custom machine instance type and shared-core instance type allowed for PostgreSQL database., invalid
	db_compute_instance_size := "db-custom-2-7680"
	zone := "us-east4-b"
	disk_size := 30
	enabled := true
	location := "us-east4"
	ipv4_enabled := true
	db_name := "argonautdev"
	user_name := "argoadmin"
	user_password := "argoadmin123#"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		// TerraformDir: "../modules/gcp/psql",
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"project_id":               project_id,
			"region":                   region,
			"db_connectivity_type":     db_connectivity_type,
			"name":                     name,
			"vpc_network_name":         vpc_network_name,
			"db_compute_instance_size": db_compute_instance_size,
			"zone":                     zone,
			"disk_size":                disk_size,
			"enabled":                  enabled,
			"location":                 location,
			"ipv4_enabled":             ipv4_enabled,
			"db_name":                  db_name,
			"user_name":                user_name,
			"user_password":            user_password,
		},
		Reconfigure: true,
		NoColor:     true,
		EnvVars:     map[string]string{"project_id": "playground-351903"},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	db_instance_ip := terraform.Output(t, terraformOptions, "public_ip_address")
	// Verify that the address is not null
	assert.NotNil(t, db_instance_ip)
}
