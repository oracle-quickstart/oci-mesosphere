/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output LoginTestInstance {
   value = "${oci_core_instance.LoginTestInstance.id}"
 }

output LoginTestBlock {
  value = "${oci_core_volume.LoginTestBlock.id}"
}

output BootNodeIP {
  value = "${oci_core_instance.LoginTestInstance.public_ip}"
}
