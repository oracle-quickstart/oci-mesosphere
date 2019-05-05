// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "MesosSlvInstance" {
  count               = "${var.NumSlaveInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosSlvInstance${count.index}"
  shape               = "${var.boot_instance_shape}"
  depends_on          = ["oci_core_volume.MesosSlvBlock"]

  create_vnic_details {
    subnet_id        = "${data.terraform_remote_state.prvsubnet.PrvSubnet}"
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "mesosslv${count.index}"
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

resource "oci_core_volume" "MesosSlvBlock" {
  count               = "${var.NumSlaveInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosSlvBlock${count.index}"
  size_in_gbs         = "${var.DiskSize}"
}

resource "oci_core_volume_attachment" "MesosSlvBlockAttach" {
  count           = "${var.NumSlaveInstances}"
  attachment_type = "paravirtualized"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.MesosSlvInstance.*.id[count.index]}"
  volume_id       = "${oci_core_volume.MesosSlvBlock.*.id[count.index]}"
  device          = "${var.consistent_drive_path}"
}
