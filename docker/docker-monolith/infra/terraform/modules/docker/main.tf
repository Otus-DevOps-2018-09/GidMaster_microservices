resource "google_compute_instance_group" "docker-hosts" {
  name        = "docker-host"
  description = "Terraform docker-host group"

  instances = [
    "${google_compute_instance.docker-host.*.self_link}"
  ]
  zone = "${var.zone}"
}
resource "google_compute_instance" "docker-host" {
  count        = "${var.count}"
  zone         = "${var.zone}"
  machine_type = "n1-standard-1"
  name         = "docker-host-${count.index}"
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }
  tags = ["docker-host"]
  network_interface {
    network = "default"
    access_config {}
  } 
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}
resource "google_compute_firewall" "firewall-docker" {
  name = "docker-machine"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["2376"]
  }
  source_ranges = "${var.source_address}"
  target_tags = ["docker-host"]
}
resource "google_compute_firewall" "firewall-reddit" {
  name = "reddit-app"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["9292"]
  }
  source_ranges = "${var.source_address}"
  target_tags = ["docker-host"]
}
