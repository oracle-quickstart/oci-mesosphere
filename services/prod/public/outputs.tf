// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

# Output the private and public IPs of the public instance
output "PublicInstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSPublicInstance.*.private_ip}"]
}

output "PublicInstancePublicIPs" {
  value = ["${oci_core_instance.DCOSPublicInstance.*.public_ip}"]
}
