/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output ProxyInstance {
   value = "${oci_core_instance.MesosProxy.id}"
 }

output PublicIP {
   value = "${oci_core_instance.MesosProxy.public_ip}"
 }

output PrivateIP {
  value = "${oci_core_instance.MesosProxy.private_ip}"
}
