// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "vcn_cidr" {
  default = "10.1.0.0/16"
}

variable "authorized_ips" {
  default = "0.0.0.0/0"
}

variable "BootStrapServer" {
  default = "130.61.109.222"
}

variable "BootStrapPort" {
  default = "80"
}

variable "instance_image_ocid" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "CentOS-7-2019.03.08-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaa2ph5vy4u7vktmf3c6zemhlncxkomvay2afrbw5vouptfbydwmtq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaahhgvnnprjhfmzynecw2lqkwhztgibz5tcs3x4d5rxmbqcmesyqta"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaavsw2452x5psvj7lzp7opjcpj3yx7or4swwzl5vrdydxtfv33sbmq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa3iltzfhdk5m6f27wcuw4ttcfln54twkj66rsbn52yemg3gi5pkqa"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaaqqbtppujg46m2twxeam2god3ktu5s6ehamexb66wsb4ll4vaxpfq"
  }
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

variable "DiskSize" {
  default = "50" // size in GBs
}

variable "volume_attachment_device" {
  default = "/dev/oracleoci/oraclevdb"
}

# Defines the the maaster nodes to deploy
variable "NumMasterInstances" {
  default = "5"
}

variable "master_instance_shape" {
  default = "VM.Standard2.4"
}

variable "BootStrapFile" {
  default = "./userdata/bootstrap"
}

# Defines the the private agent nodes to deploy
variable "NumPrivateInstances" {
  default = "5"
}

variable "private_instance_shape" {
  default = "VM.Standard2.4"
}

variable "BootStrapPrivateFile" {
  default = "./userdata/bootstrapprivate"
}

# Defines the the public agent nodes to deploy
variable "NumPublicInstances" {
  default = "3"
}

variable "public_instance_shape" {
  default = "VM.Standard2.4"
}

variable "BootStrapPublicFile" {
  default = "./userdata/bootstrappublic"
}
