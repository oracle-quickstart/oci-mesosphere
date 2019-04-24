// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_instance" "DCOSPublicInstance" {
  count               = "${var.NumPublicInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DCOSPublicInstance${count.index}"
  shape               = "${var.public_instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.PubSubnet.id}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "dcospublic${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${local.ssh_public_key}"
    user_data           = "${base64encode(file(var.BootStrapPublicFile))}"
  }
  timeouts {
    create = "60m"
  }
}
