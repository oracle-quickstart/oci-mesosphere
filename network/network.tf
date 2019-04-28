// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_virtual_network" "MesosNet" {
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosNet"
  dns_label      = "MesosNet"
}

resource "oci_core_internet_gateway" "MesosIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosIG"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"
}

resource "oci_core_route_table" "MesosRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"
  display_name   = "MesosRT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.MesosIG.id}"
  }
}

resource "oci_core_security_list" "MesosSL" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosSL"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"

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
      protocol = "6"                     # tcp
      source   = "${var.authorized_ips}"

      tcp_options {
        "min" = 80        # to allow HTTP acccess to Mesos Admin
        "max" = 80
      },
    },
    {
      protocol = "6"                     # tcp
      source   = "${var.authorized_ips}"

      tcp_options {
        "min" = 8181        # to allow HTTP acccess to Zookeeper
        "max" = 8181
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

resource "oci_core_security_list" "BastionSecLst" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "BastionSecLst"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
    },
  ]

  ingress_security_rules = [
    {
      protocol = "6"      # tcp
      source   = "${var.authorized_ips}"

      tcp_options {
        "min" = 22        # to allow SSH acccess to Linux instance
        "max" = 22
      },
    },
  ]
}

## Management Subnet

resource "oci_core_subnet" "MgtSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.50.0/24"
  display_name        = "MgtSubnet"
  dns_label           = "MgtSubnet"
  security_list_ids   = ["${oci_core_security_list.MesosSL.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosNet.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}

## Master Subnet

resource "oci_core_subnet" "MstSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.20.0/24"
  display_name        = "MstSubnet"
  dns_label           = "MstSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.MesosNet.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.MesosSL.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosNet.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}

## Private Subnet

resource "oci_core_subnet" "PrvSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.30.0/24"
  display_name        = "PrvSubnet"
  dns_label           = "PrvSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.MesosNet.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.MesosSL.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosNet.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}

## Public Subnet

resource "oci_core_subnet" "PubSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.40.0/24"
  display_name        = "PubSubnet"
  dns_label           = "PubSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.MesosNet.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.MesosSL.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosNet.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}

## Bastion Subnet

resource "oci_core_subnet" "BastionSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.60.0/24"
  display_name        = "BastionSubnet"
  dns_label           = "BastionSubnet"
  security_list_ids   = ["${oci_core_security_list.BastionSecLst.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosNet.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}
