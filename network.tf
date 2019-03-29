// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_virtual_network" "MesosVCN" {
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosVCN"
  dns_label      = "Mesosvcn"
}

resource "oci_core_internet_gateway" "MesosIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosIG"
  vcn_id         = "${oci_core_virtual_network.MesosVCN.id}"
}

resource "oci_core_route_table" "MesosRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MesosVCN.id}"
  display_name   = "MesosRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.MesosIG.id}"
  }
}

resource "oci_core_security_list" "MesosSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosSecList"
  vcn_id         = "${oci_core_virtual_network.MesosVCN.id}"

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
    },
  ]

  ingress_security_rules = [
    {
      protocol = "all"
      source   = "${var.vcn_cidr}"
    },
    {
      protocol = "6"                     # tcp
      source   = "${var.authorized_ips}"

      tcp_options {
        "min" = 22        # to allow SSH acccess to Linux instance
        "max" = 22
      },
    },
    {
      protocol = "1"         # icmp
      source   = "0.0.0.0/0"

      icmp_options {
        "type" = 3
        "code" = 4
      }
    },
  ]
}

resource "oci_core_subnet" "MesosSubnet" {
  availability_domain = ""
  cidr_block          = "10.3.20.0/24"
  display_name        = "MesosSubnet"
  dns_label           = "Mesossubnet"
#  security_list_ids   = ["${oci_core_virtual_network.MesosVCN.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.MesosSecList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosVCN.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosVCN.default_dhcp_options_id}"
}
