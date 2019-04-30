// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "MesosBootInstance" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosBootInstance"
  shape               = "${var.boot_instance_shape}"
  depends_on          = ["oci_core_volume.MesosBootBlock"]

  create_vnic_details {
    subnet_id        = "${data.terraform_remote_state.mgtsubnet.MgtSubnet}"
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "mesosboot"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid}"
  }

  metadata {
    ssh_authorized_keys = "${local.ssh_public_key}"
    user_data           = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "MesosBootBlock" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MesosBootBlock"
  size_in_gbs         = "${var.DiskSize}"
}

resource "oci_core_volume_attachment" "MesosBootBlockAttach" {
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.MesosBootInstance.id}"
  volume_id       = "${oci_core_volume.MesosBootBlock.id}"
}
