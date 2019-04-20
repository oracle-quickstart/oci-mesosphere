// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "oci_objectstorage_bucket_summaries" "statefiles1" {
  compartment_id = "${var.compartment_ocid}"
  namespace      = "${data.oci_objectstorage_namespace.ns.namespace}"

  filter {
    name   = "name"
    values = ["${oci_objectstorage_bucket.statefile1.name}"]
  }
}

data "oci_objectstorage_namespace" "ns" {}

data "oci_objectstorage_namespace_metadata" "namespace-metadata1" {
  namespace = "${data.oci_objectstorage_namespace.ns.namespace}"
}
