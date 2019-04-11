// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

# Output the private and public IPs of the master instance
output "MasterInstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.private_ip}"]
}

output "MasterInstancePublicIPs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.public_ip}"]
}

# Output the private and public IPs of the private instance
output "PrivateInstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSPrivateInstance.*.private_ip}"]
}

output "PrivateInstancePublicIPs" {
  value = ["${oci_core_instance.DCOSPrivateInstance.*.public_ip}"]
}

# Output the private and public IPs of the public instance
output "PublicInstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSPublicInstance.*.private_ip}"]
}

output "PublicInstancePublicIPs" {
  value = ["${oci_core_instance.DCOSPublicInstance.*.public_ip}"]
}
