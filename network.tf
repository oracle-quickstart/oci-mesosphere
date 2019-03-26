// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_virtual_network" "MesosVCN" {
  cidr_block     = "10.2.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MesosVCN"
  dns_label      = "mesosvcn"
}

resource "oci_core_subnet" "MesosSubnet" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  cidr_block          = "10.2.20.0/24"
  display_name        = "MesosSubnet"
  dns_label           = "Mesossubnet"
  security_list_ids   = ["${oci_core_virtual_network.MesosVCN.default_security_list_id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MesosVCN.id}"
  route_table_id      = "${oci_core_route_table.MesosRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MesosVCN.default_dhcp_options_id}"
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
