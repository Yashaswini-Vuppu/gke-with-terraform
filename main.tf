resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnetwork" {
  name          = "custom-subnetwork"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

#This firewall is used for Internal communication
resource "google_compute_firewall" "allow-internal" {
  name    = "internal-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

#This firewall is used for External access like SSH, ICMP, RDP
resource "google_compute_firewall" "allow-external" {
  name    = "external-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

#This firewall is used for GKE communication
resource "google_compute_firewall" "allow-gke" {
  name    = "gke-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "15017"]
  }

  source_ranges = ["0.0.0.0/0"]
}

#GKE cluster
resource "google_container_cluster" "primary" {
  project  = var.project
  name     = "my-gke-cluster"
  location = "asia-south1-a"

  network            = google_compute_network.vpc_network.id
  subnetwork         = google_compute_subnetwork.custom_subnetwork.id
  min_master_version = var.k8s_version

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project        = google_container_cluster.primary.project
  name           = "my-node-pool"
  cluster        = google_container_cluster.primary.name
  location       = google_container_cluster.primary.location
  version        = var.k8s_version
  node_locations = ["asia-south1-a"]
  node_count     = 1

  node_config {
    image_type   = "UBUNTU_CONTAINERD"
    disk_size_gb = "10"
    disk_type    = "pd-standard"
    machine_type = "e2-medium"
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
