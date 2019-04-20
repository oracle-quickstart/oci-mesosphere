// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

variable "region" {}

variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}

locals {
  ssh_public_key = "${file("${var.ssh_public_key_path}")}"
  ssh_private_key = "${file("${var.ssh_private_key_path}")}"
}
