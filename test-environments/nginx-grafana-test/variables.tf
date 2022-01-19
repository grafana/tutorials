variable "project" {
  default = "raintank-dev"
}

variable "name" {
  default = "grafana-nginx-tutorial"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "gce_ssh_user" {
  default = "grafana"
}

variable "gce_ssh_pub_key_file" {}

variable "image_project" {}

variable "image_family" {}

variable "build" {}

variable "machine_type" {}

variable "cpu_count" {}
