package gcppsql

import (
	_ "cloud.google.com/go/storage"
	"context"
	"fmt"
	// "github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	// "golang.org/x/net/context"
	sqladmin "google.golang.org/api/sqladmin/v1beta4"
	// "golang.org/x/oauth2/google"
	"database/sql"
	// ref: https://pkg.go.dev/github.com/lib/pq#section-readme
	_ "github.com/lib/pq" //A pure Go postgres driver for Go's database/sql package
	// "google.golang.org/api/sqladmin/v1beta4"
	"log"
	"strings"
	"testing"
)

// https://cloud.google.com/storage/docs/getting-bucket-information#storage-get-bucket-metadata-go ---> Reference for following funciton
func getDBInstanceAttributes(t *testing.T, projectid string, instance_name string) (*sqladmin.DatabaseInstance, error) {
	ctx := context.Background()

	sqladminService, err := sqladmin.NewService(ctx)

	attr, err := sqladminService.Instances.Get(projectid, instance_name).Do()

	if err != nil {
		log.Fatal(err)
	}

	return attr, err
}

// func getDBInstanceAttributes(t *testing.T, projectid string, instance_name string) (*sqladmin.DatabaseInstance, error) {
// 	ctx := context.Background()

// 	c, err := google.DefaultClient(ctx, sqladmin.CloudPlatformScope)
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	sqladminService, err := sqladmin.New(c)
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	// Project ID of the project that contains the instance.
// 	project := projectid

// 	// Database instance ID. This does not include the project ID.
// 	instance := instance_name

// 	resp, err := sqladminService.Instances.Get(project, instance).Context(ctx).Do()
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	// TODO: Change code below to process the `resp` object:
// 	fmt.Printf("%#v\n", resp)

// 	return resp, err

// }

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
	user_password := "argoadmin123"
	authorized_networks := []map[string]string{
		{"name": "allow_all", "value": "0.0.0.0/32"},
	}

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
			"authorized_networks":      authorized_networks,
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

	getinstancemetadata, _ := getDBInstanceAttributes(t, project_id, name)
	t.Log("Checking activation policy")
	assert.Equal(t, "ALWAYS", getinstancemetadata.Settings.ActivationPolicy)

	t.Log("Checking availability_type")
	assert.Equal(t, "ZONAL", getinstancemetadata.Settings.AvailabilityType)

	t.Log("Comparing postgres version")
	assert.Equal(t, "POSTGRES_12", getinstancemetadata.DatabaseVersion)

	t.Log("Comparing deletion protection policy")
	assert.Equal(t, false, getinstancemetadata.Settings.DeletionProtectionEnabled)

	t.Log("Checking Database Engine AZ ")
	assert.Equal(t, zone, getinstancemetadata.GceZone)

	t.Log("Comparing pricing plan")
	assert.Equal(t, "PER_USE", getinstancemetadata.Settings.PricingPlan)

	// t.Log("comparing Instancetype")
	// assert.Equal(t, db_compute_instance_size, getinstancemetadata.InstanceType)

	t.Log("DB Connection Testing...")
	connectionString := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", user_name, user_password, db_instance_ip, db_name)
	t.Log("Connecting to:", connectionString)
	db, err := sql.Open("postgres", connectionString)
	require.NoError(t, err, "Failed to open DB connection")

	// Make sure we clean up properly
	defer db.Close()

	// Run ping to actually test the connection
	t.Log("Ping the DB")
	if err = db.Ping(); err != nil {
		t.Fatalf("Failed to ping DB: %v", err)
	} else {

	}

	// // Create table if not exists
	// logger.Logf(t, "Create table: %s", POSTGRES_CREATE_TEST_TABLE_WITH_SERIAL)
	// if _, err = db.Exec(POSTGRES_CREATE_TEST_TABLE_WITH_SERIAL); err != nil {
	// 	t.Fatalf("Failed to create table: %v", err)
	// }

	// // Clean up
	// logger.Logf(t, "Empty table: %s", SQL_EMPTY_TEST_TABLE_STATEMENT)
	// if _, err = db.Exec(SQL_EMPTY_TEST_TABLE_STATEMENT); err != nil {
	// 	t.Fatalf("Failed to clean up table: %v", err)
	// }

	// logger.Logf(t, "Insert data: %s", POSTGRES_INSERT_TEST_ROW)
	// var testid int
	// err = db.QueryRow(POSTGRES_INSERT_TEST_ROW).Scan(&testid)
	// require.NoError(t, err, "Failed to insert data")

	// assert.True(t, testid > 0, "Data was inserted")

}
