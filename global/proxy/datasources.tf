// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket   = "tfstate_file"
    key      = "network/terraform.tfstate"
    region   = "eu-frankfurt-1"
    endpoint = "https://oscemea005.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
    force_path_style            = true
    shared_credentials_file     = "/Users/torsten/.aws/credentials"
  }
}

data "oci_core_images" "ProxyImage" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.display_name}"
  sort_by = "TIMECREATED"
}
