package gcs

import (
	"cloud.google.com/go/storage"
	"context"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"log"
	"strings"
	"testing"
)

// https://cloud.google.com/storage/docs/getting-bucket-information#storage-get-bucket-metadata-go ---> Reference for following funciton
func getBucketMetadata(t *testing.T, bucketname string) (*storage.BucketAttrs, error) {
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()
	attrs, err := client.Bucket(bucketname).Attrs(ctx)
	if err != nil {
		t.Fatal(err)
		t.Log("error while retriving bucket attributes")
	}
	return attrs, err
}

// An example of how to test the Terraform module in modules/aws/rds using Terratest.
func TestTerraformModule(t *testing.T) {
	t.Parallel()

	region := "us-east4"
	bucketname := fmt.Sprintf("gcs-private-bucket-%s", strings.ToLower(random.UniqueId()))
	storage_class := "STANDARD"
	bucket_access_level := "private"
	prefix := "terratest"
	project_id := "playground-351903"
	//default_labels := "{ \"argonaut.dev/name\":  \"gcs-test\", \"argonaut.dev/type\": \"GCS\", \"argonaut.dev/manager\":  \"argonaut.dev\", \"argonaut.dev/GCS\": \"region\", \"argonaut.dev/env/dev\":  \"true\"}"

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		// TerraformDir: "../modules/gcp/gcs",
		TerraformDir: "../",

		// Variables to pass to our Terraform code using -var options
		// "username" and "password" should not be passed from here in a production scenario.
		Vars: map[string]interface{}{
			"project_id":          project_id,
			"region":              region,
			"names":               fmt.Sprintf("[\"%s\"]", bucketname),
			"prefix":              prefix,
			"storage_class":       storage_class,
			"bucket_access_level": bucket_access_level,
			//"default_labels":      default_labels,
			"location": region,
		},
		Lock: false,
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	getbucketmetadata, err := getBucketMetadata(t, fmt.Sprintf("%s-%s-%s", prefix, region, bucketname))
	if err != nil {
		t.Fatal(err)
	}

	//Applied StorageClass should be "STANDARD"
	assert.Equal(t, "STANDARD", getbucketmetadata.StorageClass)

	//Applied BucketACL should be Private
	assert.Equal(t, strings.ToUpper(region), getbucketmetadata.Location)

	t.Log("Checking Versioning Status...")
	assert.Equal(t, false, getbucketmetadata.VersioningEnabled)
}
