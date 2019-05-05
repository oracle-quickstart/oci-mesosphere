/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosBootInstance {
   value = "${oci_core_instance.MesosBootInstance.id}"
 }

output BootNodeIP {
  value = "${oci_core_instance.MesosBootInstance.private_ip}"
}

output BootNodeIP {
 value = "${oci_core_instance.MesosBootInstance.public_ip}"
}
