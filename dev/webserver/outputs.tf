/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output WebServerInstance {
   value = "${oci_core_instance.WebServerInstance.id}"
 }

output PrivateIP {
  value = "${oci_core_instance.WebServerInstance.private_ip}"
}
