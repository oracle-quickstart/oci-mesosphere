// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_virtual_network" "DCOSVCN" {
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "DCOSVCN"
  dns_label      = "DCOSVCN"
}

resource "oci_core_internet_gateway" "DCOSIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "DCOSIG"
  vcn_id         = "${oci_core_virtual_network.DCOSVCN.id}"
}

resource "oci_core_route_table" "DCOSRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.DCOSVCN.id}"
  display_name   = "DCOSRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.DCOSIG.id}"
  }
}

resource "oci_core_security_list" "DCOSSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "DCOSSecList"
  vcn_id         = "${oci_core_virtual_network.DCOSVCN.id}"

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

## Master Subnet

resource "oci_core_subnet" "DCOSMstSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.20.0/24"
  display_name        = "DCOSMstSubnet"
  dns_label           = "DCOSMstSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.DCOSVCN.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.DCOSSecList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.DCOSVCN.id}"
  route_table_id      = "${oci_core_route_table.DCOSRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.DCOSVCN.default_dhcp_options_id}"
}

## Private Subnet

resource "oci_core_subnet" "DCOSPrvSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.30.0/24"
  display_name        = "DCOSPrvSubnet"
  dns_label           = "DCOSPrvSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.DCOSVCN.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.DCOSSecList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.DCOSVCN.id}"
  route_table_id      = "${oci_core_route_table.DCOSRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.DCOSVCN.default_dhcp_options_id}"
}

## Public Subnet

resource "oci_core_subnet" "DCOSPubSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.40.0/24"
  display_name        = "DCOSPubSubnet"
  dns_label           = "DCOSPubSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.DCOSVCN.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.DCOSSecList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.DCOSVCN.id}"
  route_table_id      = "${oci_core_route_table.DCOSRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.DCOSVCN.default_dhcp_options_id}"
}
