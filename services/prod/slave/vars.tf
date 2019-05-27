variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "availability_domain" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

locals {
  ssh_public_key = "${file("${var.ssh_public_key}")}"
  ssh_private_key = "${file("${var.ssh_private_key}")}"
}

variable "display_name" {
  default = "MesosSlave"
}

variable "DiskSize" {
  default = "50" // size in GBs
}

variable "consistent_drive_path" {
  default = "/dev/oracleoci/oraclevdb"
}

# Defines the the nodes to deploy
variable "NumSlaveInstances" {
  default = "5"
}

variable "nb_ad" {
  type = "map"

  default = {
    us-phoenix-1   = "3"
    us-ashburn-1   = "3"
    eu-frankfurt-1 = "3"
    uk-london-1    = "3"
    ca-toronto-1   = "1"
  }
}

variable "boot_instance_shape" {
  default = "VM.Standard2.4"
}
