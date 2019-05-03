/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosBaseInstance {
   value = "${oci_core_instance.MesosBaseInstance.id}"
 }

output MesosBaseBlock {
  value = "${oci_core_volume.MesosBaseBlock.id}"
}

output BaseNodeIP {
  value = "${oci_core_instance.MesosBaseInstance.private_ip}"
}
