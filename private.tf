// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

// Define Private Agent Instances

resource "oci_core_instance" "DCOSPrivateInstance" {
  count               = "${var.NumPrivateInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DCOSPrivateInstance${count.index}"
  shape               = "${var.private_instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.DCOSPrvSubnet.id}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "dcosprivate${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.BootStrapPrivateFile))}"
  }
  timeouts {
    create = "60m"
  }
}

## Block Attachments for Private Agent Nodes

resource "oci_core_volume" "DCOSPrivateBlock" {
  count               = "${var.NumPrivateInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DCOSPrivateBlock${count.index}"
  size_in_gbs         = "${var.DiskSize}"
}

resource "oci_core_volume_attachment" "DCOSPrivateBlockAttach" {
  count           = "${var.NumPrivateInstances}"
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.DCOSPrivateInstance.*.id[count.index]}"
  volume_id       = "${oci_core_volume.DCOSPrivateBlock.*.id[count.index]}"

  connection {
    agent       = false
    timeout     = "30m"
    type        = "ssh"
    host        = "${oci_core_instance.DCOSPrivateInstance.*.public_ip[count.index]}"
    user        = "opc"
    private_key = "${var.ssh_private_key}"
  }

  # register and connect the iSCSI block volume
  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
  }

  # initialize partition and file system
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "export HAS_PARTITION=$(sudo partprobe -d -s /dev/disk/by-path/$${DEVICE_ID} | wc -l)",
      "if [ $HAS_PARTITION -eq 0 ] ; then",
      "  (echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/disk/by-path/$${DEVICE_ID}",
      "  while [[ ! -e /dev/disk/by-path/$${DEVICE_ID}-part1 ]]; do sleep 5; done",
      "  sudo mkfs.xfs /dev/disk/by-path/$${DEVICE_ID}-part1",
      "fi",
    ]
  }

  # mount the partition
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "sudo mkdir -p /var/lib/dcos",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "echo 'UUID='$${UUID}' /var/lib/dcos xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab",
      "sudo mount -a",
    ]
  }

  # unmount and disconnect on destroy
  provisioner "remote-exec" {
    when       = "destroy"
    on_failure = "continue"
    inline = [
      "set -x",
      "export DEVICE_ID=ip-${self.ipv4}:${self.port}-iscsi-${self.iqn}-lun-1",
      "export UUID=$(sudo /usr/sbin/blkid -s UUID -o value /dev/disk/by-path/$${DEVICE_ID}-part1)",
      "sudo umount /var/lib/dcos",
      "if [[ $UUID ]] ; then",
      "  sudo sed -i.bak '\\@^UUID='$${UUID}'@d' /etc/fstab",
      "fi",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -u",
      "sudo iscsiadm -m node -o delete -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      ]
    }

}
