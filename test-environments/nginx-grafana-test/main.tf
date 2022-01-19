// TODO: add grafana terraform provider and use to adjust config for reverse proxy

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.80.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "ip_address" {
  name = "ip-${var.name}"
}

resource "google_compute_firewall" "default" {
  name    = "firewall-${var.name}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3000", "3001", "22", "80"]
  }
}

resource "google_compute_instance" "instance_with_ip" {
  name         = "instance-${var.name}"
  machine_type = "${var.machine_type}-standard-${var.cpu_count}"


  provisioner "remote-exec" {
    script = "./scripts/${var.build}.sh"

    connection {
      type = "ssh"
      user = "grafana"
      host = self.network_interface[0].access_config[0].nat_ip
    }
  }

  boot_disk {
    initialize_params {
      image = "${var.image_family}/${var.image_project}"
      size  = 25
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

# print ip address to console here?
output "instance_ip" {
  value = google_compute_address.ip_address.address
}