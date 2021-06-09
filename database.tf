## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_autonomous_database" "ATPdatabase" {
  admin_password           = var.atp_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.atp_cpu_core_count
  data_storage_size_in_tbs = var.atp_data_storage_size_in_tbs
  db_name                  = var.atp_db_name
  db_version               = var.atp_db_version
  display_name             = var.atp_name
  freeform_tags            = var.atp_freeform_tags
  license_model            = var.atp_license_model
  is_free_tier             = var.atp_free_tier
  nsg_ids                  = var.atp_private_endpoint ? [oci_core_network_security_group.ATPSecurityGroup.id] : null  
  private_endpoint_label   = var.atp_private_endpoint ? var.atp_private_endpoint_label : null  
  subnet_id                = var.atp_private_endpoint ? oci_core_subnet.vcn01_subnet_db01.id : null
  defined_tags             = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }  
}

resource "random_password" "wallet_password" {
  length  = 16
  special = true
}

resource "oci_database_autonomous_database_wallet" "atp_wallet" {
  autonomous_database_id = oci_database_autonomous_database.ATPdatabase.id
  password               = random_password.wallet_password.result
  base64_encode_content  = "true"
}
