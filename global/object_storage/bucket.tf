// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

locals {
  source_region = "${var.region}"
}

provider "oci" {
  region           = "${var.region}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
}

resource "oci_objectstorage_bucket" "statefile1" {
  compartment_id = "${var.compartment_ocid}"
  namespace      = "${data.oci_objectstorage_namespace.ns.namespace}"
  name           = "tfstate_file"
  access_type    = "NoPublicAccess"
}

data "oci_objectstorage_bucket_summaries" "statefiles1" {
  compartment_id = "${var.compartment_ocid}"
  namespace      = "${data.oci_objectstorage_namespace.ns.namespace}"

  filter {
    name   = "name"
    values = ["${oci_objectstorage_bucket.statefile1.name}"]
  }
}
