// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

# Output the private and public IPs of the private instance
output "PrivateInstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSPrivateInstance.*.private_ip}"]
}

output "PrivateInstancePublicIPs" {
  value = ["${oci_core_instance.DCOSPrivateInstance.*.public_ip}"]
}
