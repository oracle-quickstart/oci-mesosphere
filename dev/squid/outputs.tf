/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output SquidInstance {
   value = "${oci_core_instance.SquidInstance.id}"
 }

output PrivateIP {
  value = "${oci_core_instance.SquidInstance.private_ip}"
}

output PublicIP {
 value = "${oci_core_instance.SquidInstance.public_ip}"
}
