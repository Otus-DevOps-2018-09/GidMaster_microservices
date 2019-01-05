provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}" 
}
module "docker-host" {
  source = "modules/docker"
  count = "${var.count}"
  zone = "${var.zone}"
  public_key_path = "${var.public_key_path}"
  source_address = "${var.source_address}"
}
