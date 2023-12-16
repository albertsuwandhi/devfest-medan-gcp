# Google Cloud Storage
resource "google_storage_bucket" "devfest-medan-gcs" {
  name          = "devfest-medan-gcs"
  location      = "ASIA"
  force_destroy = true
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

}

# Firewall

# tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow-ssh-http-icmp" {
  name    = "allow-ssh-icmp"
  network = "default"

  target_tags = ["allow-ssh-http-icmp"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # Change here!
}

# Machine Image
# Example : gcloud compute images list --filter ubuntu-os-cloud

data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# # Service Account

# resource "google_service_account" "my_service_account" {
#   account_id   = "devfest-sa"
#   display_name = "devfest-sa"
# }

# Persistent Disk
resource "google_compute_disk" "data_disk" {
  name = "test-disk"
  type = "pd-ssd"
  zone = "asia-southeast2-a"
  size = 100
  # image = "debian-11-bullseye-v20220719"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}


# Google Compute Engine
resource "google_compute_instance" "vm-01" {
  name                      = "vm-01"
  machine_type              = "e2-medium" # Try : micro, small, medium
  zone                      = var.compute_zone["zone-1"]
  allow_stopping_for_update = var.allow_stop_vm

  tags = ["allow-ssh-http-icmp"]

  # lifecycle {
  #   prevent_destroy = true
  # }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  # Additional disk
  attached_disk {
    source = google_compute_disk.data_disk.id
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}
#   metadata_startup_script =  "sudo apt-get update; sudo apt-get install -y nginx; sudo systemctl start nginx" 

#   # service_account {
#   #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#   #   email  = google_service_account.my_service_account.email
#   #   scopes = ["cloud-platform"]
#   # }
# }

# resource "google_compute_instance" "vm-02" {
#   name                      = "vm-02"
#   machine_type              = "e2-small"
#   zone                      = var.compute_zone["zone-2"]
#   allow_stopping_for_update = var.allow_stop_vm


#   boot_disk {
#     initialize_params {
#       image = data.google_compute_image.ubuntu.self_link
#     }
#   }

#   network_interface {
#     network = "default"

#     access_config {
#       // Ephemeral public IP
#     }
#   }

#   #   metadata_startup_script = "echo Devfest-Medan > /DevFest.txt"

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = google_service_account.my_service_account.email
#     scopes = ["cloud-platform"]
#   }
# }


# Infracost : 
# 1. infracost breakdown --path .
# 2. infracost breakdown --sync-usage-file --usage-file infracost-usage.yml --path . 
# 3. infracost breakdown --path . --usage-file infracost-usage.yml
# 4. infracost breakdown --path . --out-file output.json --format json && infracost diff --path . --compare-to output.json 