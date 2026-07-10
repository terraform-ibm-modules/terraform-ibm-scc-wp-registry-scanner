##############################################################################
# Input Variables
##############################################################################

variable "develop_mode" {
  type        = bool
  description = "If set to true, increases the wait time for chart deployment and undeployment to facilitate cluster debugging, and prevents the `helm_release` resource from automatically rolling back changes if the helm deployment fails."
  default     = false
}

# registry scanner configuration

variable "scc_wp_registry_scanner_repository" {
  type        = string
  default     = "https://charts.sysdig.com"
  description = "Sysdig Registry Scanner repository to pull helm chart and images. Default to https://charts.sysdig.com"
  nullable    = false
}

variable "scc_wp_registry_scanner_chart_name" {
  type        = string
  default     = "registry-scanner"
  description = "Helm chart name for the Sysdig Registry Scanner"
  nullable    = false
}

variable "scc_wp_registry_scanner_chart_version" {
  type        = string
  default     = "1.11.0"
  description = "Sysdig Registry Scanner helm chart and image version"
  nullable    = false
}

variable "scc_wp_registry_scanner_namespace" {
  type        = string
  default     = "ibm-observe"
  description = "Namespace to deploy Sysdig Registry Scanner. Default to ibm-observe"
  nullable    = false
}

variable "scc_wp_registry_scanner_namespace_create" {
  type        = bool
  default     = true
  description = "Flag to enable creation of the namespace during Sysdig Registry Scanner helm release installation. Default to true."
  nullable    = false
}

variable "scc_wp_registry_scanner_helm_timeout" {
  type        = number
  default     = 600
  description = "Helm release installation timeout for the Sysdig Registry Scanner helm release installation. Default to 600s."
  nullable    = false
}

variable "scc_wp_registry_scanner_helm_recreate_pods" {
  type        = bool
  default     = true
  description = "Sysdig Registry Scanner helm release input to recreate pods. If true helm performs pods restart during upgrade/rollback. Default to true."
  nullable    = false
}

variable "scc_wp_registry_scanner_helm_force_update" {
  type        = bool
  default     = true
  description = "Force Sysdig Registry Scanner helm release resource update through delete/recreate if needed. Default to true."
  nullable    = false
}

variable "scc_wp_registry_scanner_helm_reset_values" {
  type        = bool
  default     = true
  description = "Flag to reset Sysdig Registry Scanner values to the ones built into the chart. Default to true."
}

variable "scc_wp_registry_scanner_cron_job_schedule" {
  type        = string
  default     = "0 0 * * 1"
  description = "Sysdig Registry Scanner cronjob setting. Default to run on Monday every week."
  nullable    = false
}

variable "scc_wp_instance_id" {
  type        = string
  description = "IBM Cloud instance ID for the Workload Protect SCC instance to bind the Registry Scanner to."
  nullable    = false
}

variable "scc_wp_registry_scanner_secure_api_iam_token" {
  type        = string
  description = "IAM token to authenticate on var.scc_wp_registry_scanner_secure_api_url Workload Protect SCC API instance to generate the token to authenticate on the API if var.scc_wp_registry_scanner_secure_api_token. If null and var.scc_wp_registry_scanner_secure_api_token is null the IBM Cloud provider API key is used to generate the IAM token. Default to null."
  default     = null
}

variable "scc_wp_registry_scanner_secure_api_url" {
  type        = string
  description = "URL of the Workload Protect SCC API instance to bind the Registry Scanner to. It is used also to generate the Sysdig token."
  nullable    = false
}

variable "scc_wp_registry_scanner_secure_api_token" {
  type        = string
  default     = null
  description = "API token for the Workload Protect SCC instance to bind the Registry Scanner to. If null a token will be generated using the token from var.scc_wp_registry_scanner_secure_api_iam_token or the IBM Cloud provider API key. Default to null."
  sensitive   = true
}

variable "scc_wp_registry_scanner_secure_api_skip_tls" {
  type        = bool
  default     = true
  description = "Flag to enable Skip TLS configuration on Sysdig Registry Scanner to ignore TLS certificate for IAM API. Default to true."
  nullable    = false
}

variable "scc_wp_registry_scanner_registry_url" {
  type        = string
  description = "Url of the registry scan with Sysdig Registry Scanner."
  nullable    = false
}

variable "scc_wp_registry_scanner_registry_username" {
  type        = string
  default     = "iamapikey"
  description = "Username to authenticate on the registry scan with Sysdig Registry Scanner. Default to iamapikey for IAM API key authentication."
  nullable    = false
}

variable "scc_wp_registry_scanner_registry_password" {
  type        = string
  description = "Password to authenticate on the registry scan with Sysdig Registry Scanner. If var.scc_wp_registry_scanner_registry_username is set to apikey it can be an API key value."
  nullable    = false
  sensitive   = true
}

variable "scc_wp_registry_scanner_registry_type" {
  type        = string
  default     = "icr"
  description = "Type of the registry to scan with Sysdig Registry Scanner. Default to icr."
  nullable    = false
}

variable "scc_wp_registry_scanner_registry_iam_endpoint" {
  type        = string
  default     = ""
  description = "The ICR IAM API endpoint. Default to empty."
  nullable    = false
}
