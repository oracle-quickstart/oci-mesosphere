// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "BastionInstance" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Bastion"
  shape               = "${var.boot_instance_shape}"

  create_vnic_details {
    subnet_id        = "${data.terraform_remote_state.bastionsubnet.BastionSubnet}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "bastion"
  }

  source_details {
    source_id = "${data.oci_core_images.BastionImage.images.0.id}"
    source_type = "image"
  }

  metadata {
    ssh_authorized_keys = "${local.ssh_public_key}"
    user_data = "${base64encode(file("./bootscript.tpl"))}"
  }

}
