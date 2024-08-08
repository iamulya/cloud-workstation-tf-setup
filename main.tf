variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "workstations.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  service = each.key
  disable_on_destroy = false
  disable_dependent_services = false
}

resource "google_compute_network" "default" {
  provider                = google-beta
  name                    = "workstation-vpc"
  auto_create_subnetworks = false
  depends_on = [ google_project_service.gcp_services ]
}

resource "google_compute_subnetwork" "default" {
  provider      = google-beta
  name          = "workstation-vpc-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.name
}

resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  workstation_cluster_id = "workstation-cluster"
  network                = google_compute_network.default.id
  subnetwork             = google_compute_subnetwork.default.id
  location               = "us-central1"
}

resource "google_workstations_workstation_config" "default" {
  provider               = google-beta
  workstation_config_id  = "workstation-config"
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = "us-central1"

  host {
    gce_instance {
      machine_type                = "e2-standard-2"
      boot_disk_size_gb           = 35
    }
  }
}

resource "google_workstations_workstation_config" "intellij" {
  provider               = google-beta
  workstation_config_id  = "workstation-config-intellij"
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = "us-central1"

  host {
    gce_instance {
      machine_type                = "e2-standard-4"
      boot_disk_size_gb           = 35
    }
  }

  container {
    image = "us-central1-docker.pkg.dev/cloud-workstations-images/predefined/intellij-ultimate:latest"
  }
}

resource "google_workstations_workstation" "default" {
  provider               = google-beta
  workstation_id         = "workstation-demo"
  workstation_config_id  = google_workstations_workstation_config.default.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = "us-central1"
}

resource "google_workstations_workstation" "ws_intellij" {
  provider               = google-beta
  workstation_id         = "workstation-demo-intellij"
  workstation_config_id  = google_workstations_workstation_config.intellij.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = "us-central1"
}