resource "google_compute_address" "public_loadbalencer_ip" {
  name    = "zulip-loadbalancer-ip"
  project = var.project
  region  = var.region
}

resource "kubernetes_service" "zulip" {
  metadata {
    name = "zulip"
  }

  spec {
    selector = {
      app = "zulip"
    }

    session_affinity = "None"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
      name        = "zulip-http"
    }

    port {
      protocol    = "TCP"
      port        = 443
      target_port = 443
      name        = "zulip-https"
    }

    type = "LoadBalancer"
    load_balancer_ip = google_compute_address.public_loadbalencer_ip.address
  }
}

#resource "kubernetes_persistent_volume_claim" "zulip_volume_claim" {
#  metadata {
#    name = "zulip"
#  }
#  spec {
#    storage_class_name = "standard"
#    access_modes = ["ReadWriteOnce"]
#    resources {
#      requests = {
#        storage = "50Gi"
#      }
#    }
#  }
#}

resource "google_compute_disk" "zulip_disk" {
  name    = "zulip-disk"
  project = var.project
  type    = "pd-standard"
  zone    = var.zone
  size    = 50
}

resource "kubernetes_persistent_volume" "zulip_volume" {
  metadata {
    name = "zulip-volume"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "50Gi"
    }
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.zulip_disk.name
        fs_type = "ext4"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "zulip_volume_claim" {
  metadata {
    name = "zulip-volume-claim"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.zulip_volume.metadata.0.name
    storage_class_name = "standard"
  }
}

resource "kubernetes_deployment" "zulip" {
  metadata {
    name = "zulip"

    labels = {
      app = "zulip"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "zulip"
      }
    }


    template {
      metadata {
        labels = {
          app = "zulip"
        }
      }

      spec {
        volume {
          name = "persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.zulip_volume_claim.metadata.0.name
          }
        }

        container {
          name  = "redis"
          image = "quay.io/sameersbn/redis:latest"

          resources {
            requests = {
              cpu = "50m"
              memory = "128Mi"
            }
            limits = {
              cpu = "50m"
              memory = "256Mi"
            }
          }

          env {
            name = "REDIS_PASSWORD"
            value = "REPLACE_WITH_SECURE_REDIS_PASSWORD"
          }

          volume_mount {
            name       = "persistent-storage"
            mount_path = "/var/lib/redis"
            sub_path   = "redis"
          }
        }

        container {
          name  = "memcached"
          image = "quay.io/sameersbn/memcached:latest"

          resources {
            requests = {
              cpu = "75m"
              memory = "128Mi"
            }
            limits = {
              cpu = "75m"
              memory = "256Mi"
            }
          }
        }

        container {
          name  = "rabbitmq"
          image = "rabbitmq:3.7.7"

          env {
            name  = "RABBITMQ_DEFAULT_USER"
            value = "zulip"
          }

          env {
            name  = "RABBITMQ_DEFAULT_PASS"
            value = "REPLACE_WITH_SECURE_RABBITMQ_PASSWORD"
          }

          resources {
            requests = {
              cpu = "75m"
              memory = "128Mi"
            }
            limits = {
              cpu = "75m"
              memory = "256Mi"
            }
          }

          volume_mount {
            name       = "persistent-storage"
            mount_path = "/var/lib/rabbitmq"
            sub_path   = "rabbitmq"
          }
        }

        container {
          name  = "postgresql"
          image = "zulip/zulip-postgresql"

          env {
            name  = "POSTGRES_DB"
            value = "zulip"
          }

          env {
            name  = "POSTGRES_USER"
            value = "zulip"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "REPLACE_WITH_SECURE_POSTGRES_PASSWORD"
          }

          resources {
            requests = {
              cpu = "80m"
              memory = "128Mi"
            }
            limits = {
              cpu = "80m"
              memory = "256Mi"
            }
          }

          volume_mount {
            name       = "persistent-storage"
            mount_path = "/var/lib/postgresql"
            sub_path   = "postgresql"
          }
        }

        container {
          name  = "zulip"
          image = "zulip/docker-zulip:4.8-1"

          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 443
            protocol       = "TCP"
          }

          env {
            name  = "DB_HOST"
            value = "localhost"
          }

          env {
            name  = "MEMCACHED_HOST"
            value = "localhost"
          }

          env {
            name  = "REDIS_HOST"
            value = "localhost"
          }

          env {
            name = "SECRETS_redis_password"
            value = "REPLACE_WITH_SECURE_REDIS_PASSWORD"
          }

          env {
            name  = "RABBITMQ_HOST"
            value = "localhost"
          }

          env {
            name  = "ZULIP_AUTH_BACKENDS"
            value = "EmailAuthBackend"
          }

          env {
            name  = "SECRETS_email_password"
            value = "123456789"
          }

          env {
            name  = "SETTING_EXTERNAL_HOST"
            value = "34.93.22.6"
          }

          env {
            name  = "SETTING_ZULIP_ADMINISTRATOR"
            value = "admin@example.com"
          }

          env {
            name = "SETTING_EMAIL_HOST"
          }

          env {
            name  = "SETTING_EMAIL_HOST_USER"
            value = "noreply@example.com"
          }

          env {
            name  = "ZULIP_USER_EMAIL"
            value = "example@example.com"
          }

          env {
            name  = "ZULIP_USER_DOMAIN"
            value = "example.com"
          }

          env {
            name  = "ZULIP_USER_PASS"
            value = "123456789"
          }

          env {
            name  = "SECRETS_secret_key"
            value = "REPLCAE_WITH_SECURE_SECRET_KEY"
          }

          env {
            name  = "SECRETS_postgres_password"
            value = "REPLACE_WITH_SECURE_POSTGRES_PASSWORD"
          }

          env {
            name  = "SECRETS_rabbitmq_password"
            value = "REPLACE_WITH_SECURE_RABBITMQ_PASSWORD"
          }

          env {
            name  = "SSL_CERTIFICATE_GENERATION"
            value = "self-signed"
          }

          resources {
            requests = {
              cpu = "100m"
              memory = "4Gi"
            }
            limits = {
              cpu = "100m"
              memory = "5Gi"
            }
          }

          volume_mount {
            name       = "persistent-storage"
            mount_path = "/data"
            sub_path   = "data"
          }
        }
      }
    }
  }
}

#resource "kubernetes_deployment" "zulip" {
#  metadata {
#    name = "zulip"
#
#    labels = {
#      run = "zulip"
#    }
#  }
#
#  spec {
#    replicas = 1
#
#    strategy {
#      type = "RollingUpdate"
#
#      rolling_update {
#        max_surge       = 1
#        max_unavailable = 0
#      }
#    }
#
#    selector {
#      match_labels = {
#        run = "zulip"
#      }
#    }
#
#    template {
#      metadata {
#        name = "zulip"
#        labels = {
#          run = "zulip"
#        }
#      }
#
#      spec {
#        container {
#          image = "quay.io/sameersbn/redis:latest"
#          name  = "redis"
#
#          port {
#            container_port = 8080
#          }
#
#          resources {
#            limits = {
#              cpu    = "50m"
#            }
#          }
#        }
#      }
#    }
#  }
#}