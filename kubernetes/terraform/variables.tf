variable project {
  description = "Project ID"
}

variable zone {
  description = "Zone"
}

variable cluster_name {
  description = "Cluster name"
  default     = "kubernetes-cluster"
}

variable kubernetes_version {
  description = "Kubernetes version"
  default     = "1.10.9-gke.5"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}

variable disk_size_gb {
  description = "Disk size"
  default     = 20
}

variable node_count {
  description = "Number of nodes"
  default     = 2
}

