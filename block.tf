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

  # initialize partition and file system
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4[count.index]}:${self.port[count.index]}-iscsi-${self.iqn[count.index]}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s /dev/disk/by-path/$${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -eq 0 ] ; then",
      "  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/disk/by-path/$${DEVICE_ID}",
      "  while [[ ! -e /dev/disk/by-path/$${DEVICE_ID}-part1 ]] ; do sleep 1; done",
      "  sudo mkfs.xfs /dev/disk/by-path/$${DEVICE_ID}-part1",
      "fi",
    ]
  }

  # mount the partition
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4[count.index]}:${self.port[count.index]}-iscsi-${self.iqn[count.index]}-lun-1",
      "sudo mkdir -p /mnt/vol1",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /mnt/vol1 xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
    ]
  }

  # unmount and disconnect on destroy
  provisioner "remote-exec" {
    when       = "destroy"
    on_failure = "continue"
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4[count.index]}:${self.port[count.index]}-iscsi-${self.iqn[count.index]}-lun-1",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "sudo umount /mnt/vol1",
      "if [[ $UUID ]] ; then",
      "  sudo sed -i.bak '\\@^UUID='$${UUID}'@d' /etc/fstab",
      "fi",
      "sudo iscsiadm -m node -T ${self.iqn[count.index]} -p ${self.ipv4[count.index]}:${self.port[count.index]} -u",
      "sudo iscsiadm -m node -o delete -T ${self.iqn[count.index]} -p ${self.ipv4[count.index]}:${self.port[count.index]}",
      ]
    }

}
