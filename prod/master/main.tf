// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "MesosMstInstance" {
  count               = "${var.NumMasterInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosMstInstance${count.index}"
  shape               = "${var.mst_instance_shape}"

  create_vnic_details {
    subnet_id        = "${data.terraform_remote_state.mstsubnet.MstSubnet}"
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "mesosmst${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid}"
  }

  metadata {
    ssh_authorized_keys = "${local.ssh_public_key}"
    user_data = "${base64encode(file("./bootscript.tpl"))}"
    }

  timeouts {
    create = "60m"
  }
}
