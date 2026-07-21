<!-- Update this title with a descriptive name. Use sentence case. -->
# Terraform Security and Compliance Center Workload Protection Registry Scanner

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
  3. Update the Terraform Registry badge to point to the correct published module path (replace "module-template" with the actual module name before release).
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner/ibm/latest)
<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

[IBM Cloud Security and Compliance Center Workload Protection](https://www.ibm.com/products/security-and-compliance-center) is the Cloud-Native Application Protection Platform for hybrid multicloud.
Powered by Sysdig, it detects operating system (OS) and third-party package vulnerabilities (like Node.js, Python, or Java) and a key capability is the Registry Scanner.

This module allows to deploy Registry Scanner into an OpenShift or Kubernetes cluster on IBM Cloud platform and to set its configuration parameters.

The Registry Scanner helm chart is pulled from `https://charts.sysdig.com/charts/registry-scanner/` but the origin of the helm chart can be customised with adopter's own helm chart repository if available.

For more details please refer to
- [Scanning container images for vulnerabilities in IBM Cloud](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-ocp-image-mgmt-vulnerability-scanning)
- [IBM Container Registry Scanner](https://docs.sysdig.com/en/sysdig-secure/ibm-container-registry/)

#### Sysdig token authentication

The Sysdig Registry Scanner integration doesn't currently support authentication with IAM API key or IAM token but it supports only the Sysdig token.
The module allows to use one of the following (in order of priority, according to which one of these is null):
- the Sysdig token through var.scc_wp_registry_scanner_secure_api_token
- the IAM token to generate the Sysdig token on the path `{var.scc_wp_registry_scanner_secure_api_url}/api/token`
- the IAM token generated from the provider IBM Cloud API key

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
<ul>
  <li><a href="#terraform-ibm-scc-wp-registry-scanner">terraform-ibm-scc-wp-registry-scanner</a></li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner/tree/main/examples">Examples</a>
    <ul>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner/tree/main/examples/basic">Basic example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-wp-registry-scanner-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
    </ul>
    ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
  </li>
  <li><a href="#known-issues">Known issues</a></li>
  <li><a href="#contributing">Contributing</a></li>
</ul>
<!-- END OVERVIEW HOOK -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-scc-wp-registry-scanner

### Usage

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "X.Y.Z"  # Lock into a provider version that satisfies the module constraints
    }
  }
}

module "ocp_base" {
  source                              = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version                             = "3.87.5"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = var.region
  tags                                = var.resource_tags
  cluster_name                        = "${var.prefix}-cluster"
  force_delete_storage                = true
  vpc_id                              = ibm_is_vpc.vpc.id
  vpc_subnets                         = local.cluster_vpc_subnets
  worker_pools                        = local.worker_pools
  disable_outbound_traffic_protection = true # set as True to enable outbound traffic; required for accessing Operator Hub in the OpenShift console.
}

##############################################################################
# Init cluster config for helm and kubernetes providers
##############################################################################

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = module.ocp_base.cluster_id
  resource_group_id = module.resource_group.resource_group_id
  endpoint_type     = var.cluster_config_endpoint_type != "default" ? var.cluster_config_endpoint_type : null # null represents default
}

module "sysdig_registry_scanner" {
  source                                        = "git::https://github.com/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner.git?ref=master" # replace with the required version
  develop_mode                                  = var.develop_mode
  scc_wp_registry_scanner_secure_api_url        = var.scc_wp_registry_scanner_secure_api_url
  scc_wp_registry_scanner_secure_api_token      = var.scc_wp_registry_scanner_secure_api_token
  scc_wp_registry_scanner_registry_username     = var.scc_wp_registry_scanner_registry_username
  scc_wp_instance_id                            = var.scc_wp_instance_id
  scc_wp_registry_scanner_registry_url          = var.scc_wp_registry_scanner_registry_url
  scc_wp_registry_scanner_registry_iam_endpoint = var.scc_wp_registry_scanner_registry_iam_endpoint
}
```

### Required access policies

You need the following permissions to run this module.

- IAM Services
  - **Kubernetes** service
      - `Viewer` platform access
      - `Manager` service access

For more information about the access you need to run Terraform IBM modules, see [IBM Cloud IAM roles](https://cloud.ibm.com/docs/account?topic=account-userroles).

<!-- No permissions are needed to run this module.-->


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, <4.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.59.0, < 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.scc_wp_registry_scanner](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [time_sleep.wait_helm_release](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [external_external.generate_wp_scc_token](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |
| [ibm_iam_auth_token.iamtokendata](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_develop_mode"></a> [develop\_mode](#input\_develop\_mode) | If set to true, increases the wait time for chart deployment and undeployment to facilitate cluster debugging, and prevents the `helm_release` resource from automatically rolling back changes if the helm deployment fails. | `bool` | `false` | no |
| <a name="input_scc_wp_instance_id"></a> [scc\_wp\_instance\_id](#input\_scc\_wp\_instance\_id) | IBM Cloud instance ID for the SCC Workload Protection instance to bind the Registry Scanner to. | `string` | n/a | yes |
| <a name="input_scc_wp_registry_scanner_chart_name"></a> [scc\_wp\_registry\_scanner\_chart\_name](#input\_scc\_wp\_registry\_scanner\_chart\_name) | Helm chart name for the Sysdig Registry Scanner | `string` | `"registry-scanner"` | no |
| <a name="input_scc_wp_registry_scanner_chart_version"></a> [scc\_wp\_registry\_scanner\_chart\_version](#input\_scc\_wp\_registry\_scanner\_chart\_version) | Sysdig Registry Scanner helm chart and image version | `string` | `"1.11.0"` | no |
| <a name="input_scc_wp_registry_scanner_cron_job_schedule"></a> [scc\_wp\_registry\_scanner\_cron\_job\_schedule](#input\_scc\_wp\_registry\_scanner\_cron\_job\_schedule) | Sysdig Registry Scanner cronjob setting. Default to run on Monday every week. | `string` | `"0 0 * * 1"` | no |
| <a name="input_scc_wp_registry_scanner_helm_force_update"></a> [scc\_wp\_registry\_scanner\_helm\_force\_update](#input\_scc\_wp\_registry\_scanner\_helm\_force\_update) | Force Sysdig Registry Scanner helm release resource update through delete/recreate if needed. Default to true. | `bool` | `true` | no |
| <a name="input_scc_wp_registry_scanner_helm_recreate_pods"></a> [scc\_wp\_registry\_scanner\_helm\_recreate\_pods](#input\_scc\_wp\_registry\_scanner\_helm\_recreate\_pods) | Sysdig Registry Scanner helm release input to recreate pods. If true helm performs pods restart during upgrade/rollback. Default to true. | `bool` | `true` | no |
| <a name="input_scc_wp_registry_scanner_helm_reset_values"></a> [scc\_wp\_registry\_scanner\_helm\_reset\_values](#input\_scc\_wp\_registry\_scanner\_helm\_reset\_values) | Flag to reset Sysdig Registry Scanner values to the ones built into the chart. Default to true. | `bool` | `true` | no |
| <a name="input_scc_wp_registry_scanner_helm_timeout"></a> [scc\_wp\_registry\_scanner\_helm\_timeout](#input\_scc\_wp\_registry\_scanner\_helm\_timeout) | Helm release installation timeout for the Sysdig Registry Scanner helm release installation. Default to 600s. | `number` | `600` | no |
| <a name="input_scc_wp_registry_scanner_namespace"></a> [scc\_wp\_registry\_scanner\_namespace](#input\_scc\_wp\_registry\_scanner\_namespace) | Namespace to deploy Sysdig Registry Scanner. Default to ibm-observe | `string` | `"ibm-observe"` | no |
| <a name="input_scc_wp_registry_scanner_namespace_create"></a> [scc\_wp\_registry\_scanner\_namespace\_create](#input\_scc\_wp\_registry\_scanner\_namespace\_create) | Flag to enable creation of the namespace during Sysdig Registry Scanner helm release installation. Default to true. | `bool` | `true` | no |
| <a name="input_scc_wp_registry_scanner_registry_iam_endpoint"></a> [scc\_wp\_registry\_scanner\_registry\_iam\_endpoint](#input\_scc\_wp\_registry\_scanner\_registry\_iam\_endpoint) | The ICR IAM API endpoint. Default to empty. | `string` | `""` | no |
| <a name="input_scc_wp_registry_scanner_registry_password"></a> [scc\_wp\_registry\_scanner\_registry\_password](#input\_scc\_wp\_registry\_scanner\_registry\_password) | Password to authenticate on the registry scan with Sysdig Registry Scanner. If var.scc\_wp\_registry\_scanner\_registry\_username is set to apikey it can be an API key value. | `string` | n/a | yes |
| <a name="input_scc_wp_registry_scanner_registry_type"></a> [scc\_wp\_registry\_scanner\_registry\_type](#input\_scc\_wp\_registry\_scanner\_registry\_type) | Type of the registry to scan with Sysdig Registry Scanner. Default to icr. | `string` | `"icr"` | no |
| <a name="input_scc_wp_registry_scanner_registry_url"></a> [scc\_wp\_registry\_scanner\_registry\_url](#input\_scc\_wp\_registry\_scanner\_registry\_url) | Url of the registry scan with Sysdig Registry Scanner. | `string` | n/a | yes |
| <a name="input_scc_wp_registry_scanner_registry_username"></a> [scc\_wp\_registry\_scanner\_registry\_username](#input\_scc\_wp\_registry\_scanner\_registry\_username) | Username to authenticate on the registry scan with Sysdig Registry Scanner. Default to iamapikey for IAM API key authentication. | `string` | `"iamapikey"` | no |
| <a name="input_scc_wp_registry_scanner_repository"></a> [scc\_wp\_registry\_scanner\_repository](#input\_scc\_wp\_registry\_scanner\_repository) | Sysdig Registry Scanner repository to pull helm chart and images. Default to https://charts.sysdig.com | `string` | `"https://charts.sysdig.com"` | no |
| <a name="input_scc_wp_registry_scanner_secure_api_iam_token"></a> [scc\_wp\_registry\_scanner\_secure\_api\_iam\_token](#input\_scc\_wp\_registry\_scanner\_secure\_api\_iam\_token) | IAM token to authenticate on var.scc\_wp\_registry\_scanner\_secure\_api\_url SCC Workload Protection API instance to generate the token to authenticate on the API if var.scc\_wp\_registry\_scanner\_secure\_api\_token. If null and var.scc\_wp\_registry\_scanner\_secure\_api\_token is null the IBM Cloud provider API key is used to generate the IAM token. Default to null. | `string` | `null` | no |
| <a name="input_scc_wp_registry_scanner_secure_api_skip_tls"></a> [scc\_wp\_registry\_scanner\_secure\_api\_skip\_tls](#input\_scc\_wp\_registry\_scanner\_secure\_api\_skip\_tls) | Flag to enable Skip TLS configuration on Sysdig Registry Scanner to ignore TLS certificate for IAM API. Default to false. | `bool` | `false` | no |
| <a name="input_scc_wp_registry_scanner_secure_api_token"></a> [scc\_wp\_registry\_scanner\_secure\_api\_token](#input\_scc\_wp\_registry\_scanner\_secure\_api\_token) | API token for the SCC Workload Protection instance to bind the Registry Scanner to. If null a token will be generated using the token from var.scc\_wp\_registry\_scanner\_secure\_api\_iam\_token or the IBM Cloud provider API key. Default to null. | `string` | `null` | no |
| <a name="input_scc_wp_registry_scanner_secure_api_url"></a> [scc\_wp\_registry\_scanner\_secure\_api\_url](#input\_scc\_wp\_registry\_scanner\_secure\_api\_url) | URL of the SCC Workload Protection API instance to bind the Registry Scanner to. It is used also to generate the Sysdig token. | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Known issues

<!-- Update this if any known issues or limitations -->
There are currently no known issues or limitations at this time.

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
