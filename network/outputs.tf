/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MgtSubnet {
   value = "${oci_core_subnet.MgtSubnet.id}"
 }

output MstSubnet {
  value = "${oci_core_subnet.MstSubnet.id}"
}

output PrvSubnet {
  value = "${oci_core_subnet.PrvSubnet.id}"
}

output PubSubnet {
  value = "${oci_core_subnet.PubSubnet.id}"
}
