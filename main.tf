module "internet" {
  source = "github.com/getupcloud/terraform-module-internet?ref=v1.0"
}

module "flux" {
  source = "github.com/ditointernet/terraform-module-flux?ref=779a200fdeaba17c59877c25ccaa971c48c8516a"

  git_repo                = var.flux_git_repo
  manifests_path          = var.manifests_path != "" ? var.manifests_path : "./clusters/${var.cluster_name}/gke/manifests"
  wait                    = var.flux_wait
  flux_version            = var.flux_version
  flux_install_file       = var.flux_install_file
  manifests_template_vars = local.manifests_template_vars
  debug                   = var.dump_debug
}

module "opsgenie" {
  source = "github.com/getupcloud/terraform-module-opsgenie?ref=v1.2"

  opsgenie_enabled = var.opsgenie_enabled
  cluster_name     = var.cluster_name
  customer_name    = var.customer_name
  owner_team_name  = var.opsgenie_team_name
}

module "teleport-agent" {
  source = "github.com/getupcloud/terraform-module-teleport-agent-config?ref=v0.3"

  auth_token       = var.teleport_auth_token
  cluster_name     = var.cluster_name
  customer_name    = var.customer_name
  cluster_sla      = var.cluster_sla
  cluster_provider = "gke"
  cluster_region   = var.region
}

data "google_client_config" "default" {}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "28.0.0"

  configure_ip_masq                    = var.configure_ip_masq
  datapath_provider                    = var.datapath_provider
  default_max_pods_per_node            = var.default_max_pods_per_node
  deploy_using_private_endpoint        = var.enable_private_endpoint # yes, duplicated
  enable_private_endpoint              = var.enable_private_endpoint
  enable_private_nodes                 = var.enable_private_nodes
  enable_binary_authorization          = var.enable_binary_authorization
  enable_cost_allocation               = var.enable_cost_allocation
  grant_registry_access                = var.grant_registry_access
  registry_project_ids                 = var.registry_project_ids
  monitoring_enable_managed_prometheus = var.monitoring_enable_managed_prometheus
  monitoring_enabled_components        = var.monitoring_enabled_components
  horizontal_pod_autoscaling           = var.horizontal_pod_autoscaling
  http_load_balancing                  = var.http_load_balancing
  ip_range_pods                        = var.ip_range_pods
  ip_range_services                    = var.ip_range_services
  logging_service                      = var.logging_service
  master_authorized_networks           = var.master_authorized_networks
  master_ipv4_cidr_block               = var.master_ipv4_cidr_block
  name                                 = var.cluster_name
  network_policy                       = var.network_policy
  network_project_id                   = var.network_project_id
  network                              = var.network
  node_pools_labels                    = var.node_pools_labels
  node_pools_metadata                  = var.node_pools_metadata
  node_pools_oauth_scopes              = var.node_pools_oauth_scopes
  node_pools_tags                      = var.node_pools_tags
  node_pools_taints                    = var.node_pools_taints
  node_pools                           = var.node_pools
  project_id                           = var.project_id
  release_channel                      = var.release_channel
  regional                             = var.regional
  region                               = var.region
  remove_default_node_pool             = var.remove_default_node_pool
  subnetwork                           = var.subnetwork
  zones                                = var.zones
  kubernetes_version                   = var.kubernetes_version

  depends_on = [
    shell_script.pre_create
  ]
}
