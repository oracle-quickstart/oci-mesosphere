// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

/*
 * Sets up a VCN with:
 * - NAT gateway
 * - bastion subnet and bastion instance
 * - private subnet that routes all traffic to the NAT
 * - a test instance in the private subnet
 *
 * After applying, you should be able to ssh into the private instance
 * via the bastion and verify internet access via the NAT.
 */

variable "nat_instance_shape" {
  default = "VM.Standard2.1"
}

locals {
  bastion_subnet_prefix = "${cidrsubnet(var.vcn_cidr, var.subnet_cidr_offset, 0)}"
  private_subnet_prefix = "${cidrsubnet(var.vcn_cidr, var.subnet_cidr_offset, 1)}"

  tcp_protocol  = "6"
  all_protocols = "all"
  anywhere      = "0.0.0.0/0"
}

resource "oci_core_virtual_network" "this" {
  cidr_block     = "${var.vcn_cidr}"
  dns_label      = "pp"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "proxy_prototype"
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.this.id}"
  display_name   = "nat_gateway"
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "proxy_prototype"
  vcn_id         = "${oci_core_virtual_network.this.id}"
}

resource "oci_core_subnet" "bastion" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  cidr_block          = "${local.bastion_subnet_prefix}"
  display_name        = "bastion"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.this.id}"
  route_table_id      = "${oci_core_route_table.bastion.id}"

  security_list_ids = [
    "${oci_core_security_list.bastion.id}",
  ]

  dns_label                  = "bastion"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_route_table" "bastion" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.this.id}"
  display_name   = "bastion"

  route_rules {
    destination       = "${local.anywhere}"
    network_entity_id = "${oci_core_internet_gateway.ig.id}"
  }
}

resource "oci_core_security_list" "bastion" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "bastion"
  vcn_id         = "${oci_core_virtual_network.this.id}"

  ingress_security_rules {
    source   = "${local.anywhere}"
    protocol = "${local.tcp_protocol}"

    tcp_options {
      "min" = 22
      "max" = 22
    }
  }

  egress_security_rules {
    destination = "${var.vcn_cidr}"
    protocol    = "${local.tcp_protocol}"

    tcp_options {
      "min" = 22
      "max" = 22
    }
  }
}

resource "oci_core_instance" "bastion" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "bastion"
  shape               = "${var.nat_instance_shape}"

  source_details {
    source_id   = "${var.instance_image_ocid[var.region]}"
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = "${oci_core_subnet.bastion.id}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  timeouts {
    create = "10m"
  }
}

output "bastion_public_ip" {
  value = "${oci_core_instance.bastion.public_ip}"
}

resource "oci_core_subnet" "private" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  cidr_block          = "${local.private_subnet_prefix}"
  display_name        = "private"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.this.id}"
  route_table_id      = "${oci_core_route_table.private.id}"

  security_list_ids = [
    "${oci_core_security_list.private.id}",
  ]

  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_route_table" "private" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.this.id}"
  display_name   = "private"

  route_rules = [
    {
      destination       = "${local.anywhere}"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "${oci_core_nat_gateway.nat_gateway.id}"
    },
  ]
}

resource "oci_core_security_list" "private" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "private"
  vcn_id         = "${oci_core_virtual_network.this.id}"

  ingress_security_rules {
    source   = "${local.bastion_subnet_prefix}"
    protocol = "${local.tcp_protocol}"

    tcp_options {
      "min" = 22
      "max" = 22
    }
  }

  egress_security_rules {
    destination = "${local.anywhere}"
    protocol    = "${local.all_protocols}"
  }
}

resource "oci_core_instance" "private" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % var.nb_ad[var.region]],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "private_test_instance"
  shape               = "${var.nat_instance_shape}"

  source_details {
    source_id   = "${var.instance_image_ocid[var.region]}"
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.private.id}"
    assign_public_ip = false
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  timeouts {
    create = "10m"
  }
}

output "private_instance_ip" {
  value = "${oci_core_instance.private.private_ip}"
}

output "example_ssh_command" {
  value = "ssh -i $PRIVATE_KEY_PATH -o ProxyCommand=\"ssh -i $PRIVATE_KEY_PATH opc@${oci_core_instance.bastion.public_ip} -W %h:%p %r\" opc@${oci_core_instance.private.private_ip}"
}
