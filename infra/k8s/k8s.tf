data "google_client_config" "provider" {}

provider "kubernetes" {
  #host     = var.host
  #host    = google_container_cluster.mentorapp.endpoint
  host  = "https://${var.host}"
  #host  =  data.google_container_cluster.mentorapp.endpoint
  token = data.google_client_config.provider.access_token

  client_certificate     = "${base64decode(var.client_certificate)}"
  client_key             = "${base64decode(var.client_key)}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"

  #host                   = module.cluster_auth.host
  #token                  = module.cluster_auth.token
  #cluster_ca_certificate = module.cluster_auth.cluster_ca_certificate
}