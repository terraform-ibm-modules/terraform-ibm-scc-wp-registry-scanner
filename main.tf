# getting IAM token

locals {
  # IAM token to authenticate on scc_wp_registry_scanner_secure_api_url to generate the WP SCC API token
  scc_wp_registry_scanner_secure_api_iam_token = var.scc_wp_registry_scanner_secure_api_iam_token != null ? var.scc_wp_registry_scanner_secure_api_iam_token : data.ibm_iam_auth_token.iamtokendata.iam_access_token
}

data "ibm_iam_auth_token" "iamtokendata" {
}

data "external" "generate_wp_scc_token" {
  count = var.scc_wp_registry_scanner_secure_api_token == null ? 1 : 0
  program = [
    "${path.module}/scripts/generate_wp_scc_token.sh",
    local.scc_wp_registry_scanner_secure_api_iam_token,
    var.scc_wp_registry_scanner_secure_api_url,
    var.scc_wp_instance_id
  ]
}

locals {
  # Wait periods are overall conservative on purpose to cover majority of case.
  sleep_create  = var.develop_mode ? 300 : 60
  sleep_destroy = var.develop_mode ? 180 : 30

  scc_wp_registry_scanner_secure_api_token = var.scc_wp_registry_scanner_secure_api_token != null ? var.scc_wp_registry_scanner_secure_api_token : data.external.generate_wp_scc_token[0].result.token
}

# getting IAM account details
data "ibm_iam_account_settings" "iam_account_settings" {
}

resource "helm_release" "scc_wp_registry_scanner" {
  name             = "sysdig-registry-scanner-helm-release"
  repository       = var.scc_wp_registry_scanner_repository
  chart            = var.scc_wp_registry_scanner_chart_name
  version          = var.scc_wp_registry_scanner_chart_version
  namespace        = var.scc_wp_registry_scanner_namespace
  create_namespace = var.scc_wp_registry_scanner_namespace_create
  timeout          = var.scc_wp_registry_scanner_helm_timeout
  wait             = true
  recreate_pods    = var.scc_wp_registry_scanner_helm_recreate_pods
  force_update     = var.scc_wp_registry_scanner_helm_force_update
  reset_values     = var.scc_wp_registry_scanner_helm_reset_values
  atomic           = !var.develop_mode

  set = [{
    name  = "cronjob.schedule"
    type  = "string"
    value = var.scc_wp_registry_scanner_cron_job_schedule
    }, {
    name  = "config.secureBaseURL"
    type  = "string"
    value = var.scc_wp_registry_scanner_secure_api_url
    }, {
    name  = "config.secureAPIToken"
    type  = "string"
    value = local.scc_wp_registry_scanner_secure_api_token
    }, {
    name  = "config.secureSkipTLS"
    value = var.scc_wp_registry_scanner_secure_api_skip_tls
    }, {
    name  = "config.registryURL"
    type  = "string"
    value = var.scc_wp_registry_scanner_registry_url
    }, {
    name  = "config.registryUser"
    type  = "string"
    value = var.scc_wp_registry_scanner_registry_username
    }, {
    name  = "config.registryPassword"
    type  = "string"
    value = var.scc_wp_registry_scanner_registry_password
    }, {
    name  = "config.registryType"
    type  = "string"
    value = var.scc_wp_registry_scanner_registry_type
    }, {
    name  = "config.icrIamApi"
    type  = "string"
    value = var.scc_wp_registry_scanner_registry_iam_endpoint
    }, {
    name  = "config.registryAccountId"
    type  = "string"
    value = data.ibm_iam_account_settings.iam_account_settings.account_id
    }
  ]
}

# On create: give time for the registry scanner to warm-up up
# On delete: give time for the registry scanner to be removed (which depends on running finalizer)
resource "time_sleep" "wait_helm_release" {
  depends_on       = [helm_release.scc_wp_registry_scanner]
  create_duration  = "${local.sleep_create}s"
  destroy_duration = "${local.sleep_destroy}s"
}
