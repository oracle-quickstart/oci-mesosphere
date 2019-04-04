// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_volume" "DCOSBlock" {
  count               = "${var.NumInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DCOSBlock${count.index}"
  size_in_gbs         = "${var.DiskSize}"
}

resource "oci_core_volume_attachment" "DCOSBlockAttach" {
  count           = "${var.NumInstances}"
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.DCOSInstance.*.id[count.index]}"
  volume_id       = "${oci_core_volume.DCOSBlock.*.id[count.index]}"
  device          = "${count.index == 0 ? var.volume_attachment_device : ""}"

  connection {
    agent       = false
    timeout     = "30m"
    host        = "${oci_core_instance.DCOSInstance.*.public_ip[count.index]}"
    user        = "opc"
    private_key = "${var.ssh_private_key}"
  }

  # register and connect the iSCSI block volume

  provisioner "remote-exec" {
    inline = [
      "touch ~/IMadeAFile.Right.Here",
      "sudo iscsiadm -m node -o new -T ${self.iqn[count.index]} -p ${self.ipv4[count.index]}:${self.port[count.index]}",
      "sudo iscsiadm -m node -o update -T ${self.iqn[count.index]} -n node.startup -v automatic",
      "echo sudo iscsiadm -m node -T ${self.iqn[count.index]} -p ${self.ipv4[count.index]}:${self.port[count.index]} -l >> ~/.bashrc",
    ]
  }

  # Set this to enable CHAP authentication for an ISCSI volume attachment. The oci_core_volume_attachment resource will
  # contain the CHAP authentication details via the "chap_secret" and "chap_username" attributes.
  #use_chap = true

  # Set this to attach the volume as read-only.
  #is_read_only = true
}
