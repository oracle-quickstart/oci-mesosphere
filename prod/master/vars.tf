variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

locals {
  ssh_public_key = "${file("${var.ssh_public_key}")}"
  ssh_private_key = "${file("${var.ssh_private_key}")}"
}

variable "instance_image_ocid" {
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa5o2632n3nykduszon2ovdswn734huv7yhidvovnxol3447shtdgq"
}

variable "availability_domain" {
  default = "sDei:EU-FRANKFURT-1-AD-1"
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

# Defines the the nodes to deploy
variable "NumMasterInstances" {
  default = "5"
}

variable "mst_instance_shape" {
  default = "VM.DenseIO1.4"
}
