// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

## Define Master Instances

resource "oci_core_instance" "DCOSMasterInstance" {
  count               = "${var.NumMasterInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DCOSMasterInstance${count.index}"
  shape               = "${var.master_instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.DCOSMstSubnet.id}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "dcosmaster${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.BootStrapFile))}"
  }
  timeouts {
    create = "60m"
  }
}

## Define Private Agent Instances

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

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.BootStrapPrivateFile))}"
  }
  timeouts {
    create = "60m"
  }
}

## Define Public Agent Instances

resource "oci_core_instance" "DCOSPublicInstance" {
  count               = "${var.NumPublicInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index / var.nb_ad[var.region]) % 3 + 1}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DCOSPublicInstance${count.index}"
  shape               = "${var.public_instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.DCOSPubSubnet.id}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "dcospublic${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.BootStrapPublicFile))}"
  }
  timeouts {
    create = "60m"
  }
}
