// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"

// Ensure every example directory has a corresponding test
const basicExampleDir = "examples/basic"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	// getting apikey to use as registry password
	ibmcloud_apiKey := os.Getenv("IBM_CLOUD_API_KEY")

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        "us-south", // hardconfing region to use SCC WP instance from the same region
		TerraformVars: map[string]interface{}{
			"scc_wp_registry_scanner_registry_password":     ibmcloud_apiKey, // pragma: allowlist secret
			"scc_wp_registry_scanner_secure_api_url":        permanentResources["scc_wp_secure_api_url"],
			"scc_wp_instance_id":                            permanentResources["scc_wp_instance_id"],
			"scc_wp_registry_scanner_registry_url":          "https://private.us-south.icr.io",   // hardconfing region to use SCC WP instance from the same region
			"scc_wp_registry_scanner_registry_iam_endpoint": "https://private.iam.cloud.ibm.com", // hardconfing region to use SCC WP instance from the same region
		},
	})
	return options
}

// Consistency test for the basic example
func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sccpwp-basic", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// Upgrade test (using advanced example)
func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sccpwp-basic-upg", basicExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
