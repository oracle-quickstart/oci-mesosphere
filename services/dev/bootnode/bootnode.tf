// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.


resource "oci_core_instance" "LoginTestInstance" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "LoginTestInstance"
  shape               = "${var.boot_instance_shape}"
  depends_on          = ["oci_core_volume.LoginTestBlock"]

  create_vnic_details {
    subnet_id        = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaapc46xrzqowuy66czhbssdfingus2r27dyiutap3umsx4hqej5d3a"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "LoginTest"
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

resource "oci_core_volume" "LoginTestBlock" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "LoginTestBlock"
  size_in_gbs         = "${var.DiskSize}"
}

resource "oci_core_volume_attachment" "LoginTestBlockAttach" {
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.LoginTestInstance.id}"
  volume_id       = "${oci_core_volume.LoginTestBlock.id}"
  device          = "/dev/oracleoci/oraclevdb"
}

resource "null_resource" "diskmount" {
  triggers {
    bn_public_ip = "${oci_core_instance.LoginTestInstance.public_ip}"
    va_block_id   = "${oci_core_volume_attachment.LoginTestBlockAttach.id}"
  }

  provisioner "file" {
    source      = "diskmount.sh"
    destination = "/tmp/diskmount.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'This is the mesos bootstrap node' | sudo tee /etc/motd",
      "echo ${oci_core_instance.LoginTestInstance.public_ip} > /tmp/public.ip",
      "echo ${oci_core_instance.LoginTestInstance.private_ip} > /tmp/private.ip",
      "chmod +x /tmp/diskmount.sh",
      "sudo /tmp/diskmount.sh",
      "sudo rm -r /tmp/diskmount.sh"
    ]
  }

  connection {
    timeout     = "30m"
    type        = "ssh"
    host        = "${oci_core_instance.LoginTestInstance.public_ip}"
    user        = "opc"
    private_key = "${local.ssh_private_key}"
  }
}
