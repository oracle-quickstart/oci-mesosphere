/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosPubInstance {
   value = "${oci_core_instance.MesosPubInstance.*.id}"
 }

output MesosPubBlock {
  value = "${oci_core_volume.MesosPubBlock.*.id}"
}

output PrivateIP {
  value = "${oci_core_instance.MesosPubInstance.*.private_ip}"
}

output PublicIP {
  value = "${oci_core_instance.MesosPubInstance.*.public_ip}"
}
