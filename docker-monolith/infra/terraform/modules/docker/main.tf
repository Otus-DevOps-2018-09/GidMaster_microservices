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
