terraform {
  required_version = ">= 0.11.8"

  backend "gcs" {
    bucket = "kaypoh-scheduler-bucket"
    prefix = "terraform"
  }
}

provider "google" {
  version = "~> 1.19"
  project = "kaypoh-scheduler"
}

resource "google_container_cluster" "cluster" {
  name = "app-cluster"
  zone = "us-central1"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }
}

resource "google_container_node_pool" "np" {
  name               = "default-node-pool"
  zone               = "us-central1-a"
  cluster            = "${google_container_cluster.cluster.name}"
  initial_node_count = 1

  node_config {
    preemptible  = true
    machine_type = "f1-standard"

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }
}
