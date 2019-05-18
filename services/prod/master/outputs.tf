// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

# Output the private and public IPs of the master instance
output "MasterInstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.private_ip}"]
}

output "MasterInstancePublicIPs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.public_ip}"]
}
