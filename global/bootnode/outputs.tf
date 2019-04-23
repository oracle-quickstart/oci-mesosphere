/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosBootInstance {
   value = "${oci_core_instance.MesosBootInstance.id}"
 }

output MesosBootBlock {
  value = "${oci_core_volume.MesosBootBlock.id}"
}

output BootNodeIP {
  value = "${oci_core_instance.MesosBootInstance.public_ip}"
}
