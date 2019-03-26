// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_identity_tag_namespace" "tag-namespace1" {
  #Required
  compartment_id = "${var.compartment_ocid}"
  description    = "${var.tag_namespace_description}"
  name           = "${var.tag_namespace_name}"
}

resource "oci_identity_tag" "tag1" {
  #Required
  description      = "Mesos Tag"
  name             = "Mesos-tag"
  tag_namespace_id = "${oci_identity_tag_namespace.tag-namespace1.id}"
}

resource "oci_identity_tag" "tag2" {
  #Required
  description      = "Mesos Tag 2"
  name             = "Mesos-tag-2"
  tag_namespace_id = "${oci_identity_tag_namespace.tag-namespace1.id}"
}
