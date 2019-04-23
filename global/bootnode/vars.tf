variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}

locals {
  ssh_public_key = "${file("${var.ssh_public_key_path}")}"
  ssh_private_key = "${file("${var.ssh_private_key_path}")}"
}

variable "instance_image_ocid" {
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaapnqtqas327xtzkd446ujqbxuws45zxjwuxdx7nkc4bwzkjl7n2jq"
}

variable "availability_domain" {
  default = "sDei:EU-FRANKFURT-1-AD-1"
}

variable "DiskSize" {
  default = "50" // size in GBs
}

# Defines the the nodes to deploy
variable "NumMasterInstances" {
  default = "1"
}

variable "boot_instance_shape" {
  default = "VM.Standard2.2"
}

variable "BootStrapFile" {
  default = "./bootstrap"
}
