/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output BastionInstance {
   value = "${oci_core_instance.BastionInstance.id}"
 }

output PublicIP {
   value = "${oci_core_instance.BastionInstance.public_ip}"
 }

output PrivateIP {
  value = "${oci_core_instance.BastionInstance.private_ip}"
}
