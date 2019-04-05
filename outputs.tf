// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

# Output the private and public IPs of the instance
output "InstancePrivateIPs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.private_ip}"]
}

output "InstancePublicIPs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.public_ip}"]
}

/*
# Output the boot volume IDs of the instance
output "BootVolumeIDs" {
  value = ["${oci_core_instance.DCOSMasterInstance.*.boot_volume_id}"]
}

output "InstanceDevices" {
  value = ["${data.oci_core_instance_devices.DCOSMasterInstanceDevices.devices}"]
}
*/

# Output the chap secret information for ISCSI volume attachments. This can be used to output
# CHAP information for ISCSI volume attachments that have "use_chap" set to true.
#output "IscsiVolumeAttachmentChapUsernames" {
#  value = ["${oci_core_volume_attachment.DCOSMasterBlockAttach.*.chap_username}"]
#}
#
#output "IscsiVolumeAttachmentChapSecrets" {
#  value = ["${oci_core_volume_attachment.DCOSMasterBlockAttach.*.chap_secret}"]
#}
