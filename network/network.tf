// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

locals {
  bastion_subnet_prefix = "${cidrsubnet(var.vcn_cidr, var.subnet_cidr_offset, 0)}"
  private_subnet_prefix = "${cidrsubnet(var.vcn_cidr, var.subnet_cidr_offset, 1)}"

  ad = "${var.availability_domain}"

  tcp_protocol  = "6"
  all_protocols = "all"
  anywhere      = "0.0.0.0/0"
}

resource "oci_core_virtual_network" "MesosNet" {
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosNet"
  dns_label      = "MesosNet"
}

resource "oci_core_internet_gateway" "MesosIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "IntntGtw"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"
}

resource "oci_core_nat_gateway" "MesosNG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"
  display_name   = "NatGtw"
}


resource "oci_core_route_table" "MesosPubRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"
  display_name   = "pubtable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.MesosIG.id}"
  }
}

resource "oci_core_route_table" "MesosPrvRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"
  display_name   = "prvtable"

  route_rules = [
    {
      destination       = "${local.anywhere}"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "${oci_core_nat_gateway.MesosNG.id}"
    },
  ]
}

resource "oci_core_security_list" "MesosNAT" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "prvseclist"
  vcn_id         = "${oci_core_virtual_network.MesosNet.id}"

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

resource "oci_core_security_list" "MesosSL" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "pubseclist"
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
        "min" = 80        # to allow HTTP acccess to Mesos Admin
        "max" = 80
      },
    },
    {
      protocol = "6"                     # tcp
      source   = "${var.authorized_ips}"

      tcp_options {
        "min" = 10339        # to allow Kibana acccess for demo
        "max" = 10339
      },
    },
    {
      protocol = "6"                     # tcp
      source   = "${var.authorized_ips}"

      tcp_options {
        "min" = 10500        # to allow Kafka acccess via WebSocket
        "max" = 10500
      },
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
  route_table_id      = "${oci_core_route_table.MesosPrvRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}

## Master Subnet

resource "oci_core_subnet" "MstSubnet" {
  availability_domain = ""
  cidr_block          = "10.1.20.0/29"
  display_name        = "MstSubnet"
  dns_label           = "MstSubnet"
#  security_list_ids   = ["${oci_core_virtual_network.MesosNet.default_security_list_id}"]
  security_list_ids   = ["${oci_core_security_list.MesosSL.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosNet.id}"
  route_table_id      = "${oci_core_route_table.MesosPrvRT.id}"
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
  route_table_id      = "${oci_core_route_table.MesosPrvRT.id}"
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
  route_table_id      = "${oci_core_route_table.MesosPubRT.id}"
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
  route_table_id      = "${oci_core_route_table.MesosPubRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosNet.default_dhcp_options_id}"
}
