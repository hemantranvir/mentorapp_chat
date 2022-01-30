#####################################################################
# Variables
#####################################################################
variable "project" {}
variable "region" {}
variable "zone" {}

#####################################################################
# Modules
#####################################################################
module "compute" {
  source   = "./compute"
  project  = "${var.project}"
  region   = "${var.region}"
  zone     = "${var.zone}"
}

module "gke" {
  source   = "./gke"
  project  = "${var.project}"
  region   = "${var.region}"
  zone     = "${var.zone}"
}

module "k8s" {
  source   = "./k8s"
  host     = "${module.gke.host}"
  project  = "${var.project}"
  region   = "${var.region}"
  zone     = "${var.zone}"

  client_certificate     = "${module.gke.client_certificate}"
  client_key             = "${module.gke.client_key}"
  cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"
}