#####################################################################
# GKE Cluster
#####################################################################
resource "google_container_cluster" "mentorapp" {
  name               = "mentorapp"
  location           = var.zone
  initial_node_count = 1
  remove_default_node_pool = true

  cluster_autoscaling {
    enabled = true

    resource_limits {
      resource_type = "cpu"
      maximum = 2
      minimum = 0
    }

    resource_limits {
      resource_type = "memory"
      maximum = 10
      minimum = 0
    }
  }
}

#module "cluster_auth" {
#  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
#
#  project_id   = var.project
#  cluster_name = google_container_cluster.mentorapp.name
#  location     = var.zone
#}

resource "google_container_node_pool" "default" {
  name               = "default"
  cluster            = google_container_cluster.mentorapp.name
  location           = var.zone
  
  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = "e2-standard-2"
    
    # Required to be able to pull images from container registry
    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring"
    ]
  }
}

#####################################################################
# Output for K8S
#####################################################################
output "client_certificate" {
  value     = "${google_container_cluster.mentorapp.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.mentorapp.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.mentorapp.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.mentorapp.endpoint}"
  sensitive = true
}