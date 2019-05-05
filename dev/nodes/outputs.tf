/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosSlvInstance {
   value = "${oci_core_instance.MesosSlvInstance.*.id}"
 }

output MesosSlvBlock {
  value = "${oci_core_volume.MesosSlvBlock.*.id}"
}

output MesosNodeIP {
  value = "${oci_core_instance.MesosSlvInstance.*.private_ip}"
}
