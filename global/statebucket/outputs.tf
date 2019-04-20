/*
 * This file reads and puts out the object storage namespace and namespace_metadata.
 */

output namespace {
  value    = "${data.oci_objectstorage_namespace.ns.namespace}"
}

output namespace_metadata {
  value = <<EOF
  namespace = ${data.oci_objectstorage_namespace_metadata.namespace-metadata1.namespace}
  default_s3compartment_id = ${data.oci_objectstorage_namespace_metadata.namespace-metadata1.default_s3compartment_id}
  default_swift_compartment_id = ${data.oci_objectstorage_namespace_metadata.namespace-metadata1.default_swift_compartment_id}
EOF
}
