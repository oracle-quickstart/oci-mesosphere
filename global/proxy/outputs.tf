/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output ProxyInstance {
   value = "${oci_core_instance.ProxyInstance.id}"
 }

output PublicIP {
   value = "${oci_core_instance.ProxyInstance.public_ip}"
 }

output PrivateIP {
  value = "${oci_core_instance.ProxyInstance.private_ip}"
}
