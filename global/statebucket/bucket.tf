// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_objectstorage_namespace_metadata" "namespace-metadata1" {
  namespace                    = "${data.oci_objectstorage_namespace.ns.namespace}"
  default_s3compartment_id     = "${var.compartment_ocid}"
  default_swift_compartment_id = "${var.compartment_ocid}"
}

resource "oci_objectstorage_bucket" "statefile1" {
  compartment_id = "${var.compartment_ocid}"
  namespace      = "${data.oci_objectstorage_namespace.ns.namespace}"
  name           = "tfstate_file"
  access_type    = "NoPublicAccess"
}
