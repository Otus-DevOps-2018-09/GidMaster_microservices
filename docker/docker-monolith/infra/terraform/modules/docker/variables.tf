variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
  default     = "ubuntu-1604-lts"
}
variable count {
  description = "Number of instances"
  default     = 1
}
variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}
variable source_address {
  description = "Source address range"
  default    = ["0.0.0.0/0"]
}
