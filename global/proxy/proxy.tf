// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "ProxyInstance" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "ProxyInstance"
  shape               = "${var.boot_instance_shape}"

  create_vnic_details {
    subnet_id        = "${data.terraform_remote_state.pubsubnet.PubSubnet}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "proxy"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid}"
  }

  metadata {
    ssh_authorized_keys = "${local.ssh_public_key}"
    user_data = "${base64encode(file("./bootscript.tpl"))}"
  }

}
