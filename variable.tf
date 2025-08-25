variable "project" {
  description = " This is GCP project-id"
  type        = string
  default     = "sharp-ring-407510"
}

variable "region" {
  description = " This is GCP region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = " This is GCP zone"
  type        = string
  default     = "asia-south1-a"
}

variable "k8s_version" {
  description = " This is gke version"
  type        = string
  default     = "1.33.3-gke.1136000"
}