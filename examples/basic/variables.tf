variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API Key for a user / serviceId with write access to the corresponding namespace in the OCP cluster"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "wpscc-basic"
}

variable "region" {
  type        = string
  description = "Region where resources are created"
}

variable "resource_group" {
  type        = string
  description = "Optionally pass an existing resource group name to be used. If not passed a new one will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "develop_mode" {
  type        = bool
  description = "If set to true, increases the wait time for chart deployment and undeployment to facilitate cluster debugging, and prevents the `helm_release` resource from automatically rolling back changes if the helm deployment fails."
  default     = false
}

variable "cluster_config_endpoint_type" {
  description = "Specify which type of endpoint to use for for cluster config access: 'default', 'private', 'vpe', 'link'. 'default' value will use the default endpoint of the cluster."
  type        = string
  default     = "default"
  nullable    = false
  validation {
    error_message = "Invalid Endpoint Type. Valid values are 'default', 'private', 'vpe', or 'link'"
    condition     = contains(["default", "private", "vpe", "link"], var.cluster_config_endpoint_type)
  }
}

variable "scc_wp_instance_id" {
  type        = string
  description = "IBM Cloud instance ID for the SCC Workload Protection instance to bind the Registry Scanner to."
  nullable    = false
}

variable "scc_wp_registry_scanner_secure_api_url" {
  type        = string
  default     = "https://private.us-south.security-compliance-secure.cloud.ibm.com" # us-south.security-compliance-secure.cloud.ibm.com
  description = "URL of the SCC Workload Protection API instance to bind the Registry Scanner to. It is used also to generate the Sysdig token."
  nullable    = false
}

variable "scc_wp_registry_scanner_secure_api_token" {
  type        = string
  default     = null
  description = "API token for the SCC Workload Protection instance to bind the Registry Scanner to. If null a token will be generated using the token from var.scc_wp_registry_scanner_secure_api_iam_token or the IBM Cloud provider API key. Default to null."
  sensitive   = true
}

variable "scc_wp_registry_scanner_registry_username" {
  type        = string
  default     = "iamapikey"
  description = "Username to authenticate on the registry scan with Sysdig Registry Scanner. Default to iamapikey for IAM API key authentication."
}

variable "scc_wp_registry_scanner_registry_password" {
  type        = string
  description = "Password to authenticate on the registry scan with Sysdig Registry Scanner. If var.scc_wp_registry_scanner_registry_username is set to apikey it can be an API key value."
  sensitive   = true
}

variable "scc_wp_registry_scanner_registry_url" {
  type        = string
  description = "Sysdig Registry Scanner registry URL to scan."
  nullable    = false
}

variable "scc_wp_registry_scanner_registry_iam_endpoint" {
  type        = string
  default     = ""
  description = "The ICR IAM API endpoint. Default to empty."
  nullable    = false
}
