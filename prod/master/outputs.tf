/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output MesosMstInstance {
   value = "${oci_core_instance.MesosMstInstance.*.id}"
 }

output "MasterInstancePrivateIPs" {
   value = ["${oci_core_instance.MesosMstInstance.*.private_ip}"]
 }
