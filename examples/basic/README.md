# Basic example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=scc-wp-registry-scanner-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-scc-wp-registry-scanner/tree/main/examples/basic">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

<!--
The basic example should call the module(s) stored in this repository with a basic configuration.
Note, there is a pre-commit hook that will take the title of each example and include it in the repos main README.md.
The text below should describe exactly what resources are provisioned / configured by the example.
-->

An end-to-end basic example that will provision the following:
- A new resource group, if an existing one is not passed in.
- A VPC with a single subnet and a public gateway in a single zone.
- A single zone Red Hat OpenShift VPC cluster.
- The SCC Workload Protection Registry Scanner deployed on the cluster through the root level module, configured to scan an IBM Cloud Container Registry. If an SCC Workload Protection API token is not passed in, one is generated for the given SCC Workload Protection instance using the IAM identity of the IBM Cloud provider.

> [!NOTE]
> The token generation script reaches the SCC Workload Protection API from the machine running Terraform, so `scc_wp_registry_scanner_secure_api_url` must point to an endpoint reachable from that machine (the public endpoint when running outside the IBM Cloud private network).
