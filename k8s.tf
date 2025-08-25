# Get current Google Cloud client config
data "google_client_config" "default" {}

# Kubernetes provider config - connect Terraform to GKE
provider "kubernetes" {
  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}

# Deploy a Pod to GKE
resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-pod"
    labels = {
      app = "nginx"
    }
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest"

      port {
        container_port = 80
      }
    }
  }
}

# Optional: Expose Pod via LoadBalancer Service
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
