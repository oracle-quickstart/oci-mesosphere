// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "null_resource" "remote-exec" {
  depends_on = ["oci_core_instance.DCOSInstance", "oci_core_volume_attachment.DCOSBlockAttach"]
  count      = "${var.NumInstances}"

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.DCOSInstance.*.public_ip[count.index]}"
      user        = "opc"
      private_key = "${var.ssh_private_key}"
    }

    inline = [
      "touch ~/IMadeAFile.Right.Here",
      "sudo iscsiadm -m node -o new -T ${oci_core_volume_attachment.DCOSBlockAttach.*.iqn[count.index]} -p ${oci_core_volume_attachment.DCOSBlockAttach.*.ipv4[count.index]}:${oci_core_volume_attachment.DCOSBlockAttach.*.port[count.index]}",
      "sudo iscsiadm -m node -o update -T ${oci_core_volume_attachment.DCOSBlockAttach.*.iqn[count.index]} -n node.startup -v automatic",
      "echo sudo iscsiadm -m node -T ${oci_core_volume_attachment.DCOSBlockAttach.*.iqn[count.index]} -p ${oci_core_volume_attachment.DCOSBlockAttach.*.ipv4[count.index]}:${oci_core_volume_attachment.DCOSBlockAttach.*.port[count.index]} -l >> ~/.bashrc",
    ]
  }
}
