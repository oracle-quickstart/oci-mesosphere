/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosInstance {
   value = "${oci_core_instance.MesosInstance.id}"
 }

output MesosBlock {
  value = "${oci_core_volume.MesosBlock.id}"
}

output BaseNodeIP {
  value = "${oci_core_instance.MesosInstance.private_ip}"
}
