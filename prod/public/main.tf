// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "MesosPubInstance" {
  count               = "${var.NumPublicInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosPubInstance${count.index}"
  shape               = "${var.boot_instance_shape}"
  depends_on          = ["oci_core_volume.MesosPubBlock"]

  create_vnic_details {
    subnet_id        = "${data.terraform_remote_state.pubsubnet.PubSubnet}"
    display_name     = "primaryvnic"
    assign_public_ip = true 
    hostname_label   = "mesospub${count.index}"
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

resource "oci_core_volume" "MesosPubBlock" {
  count               = "${var.NumPublicInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosPubBlock${count.index}"
  size_in_gbs         = "${var.DiskSize}"
}

resource "oci_core_volume_attachment" "MesosPubBlockAttach" {
  count           = "${var.NumPublicInstances}"
  attachment_type = "paravirtualized"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.MesosPubInstance.*.id[count.index]}"
  volume_id       = "${oci_core_volume.MesosPubBlock.*.id[count.index]}"
  device          = "${var.consistent_drive_path}"
}
