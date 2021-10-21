## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "oci-adb" {
  source                                = "github.com/oracle-quickstart/oci-adb"
  adb_password                          = var.atp_password
  compartment_ocid                      = var.compartment_ocid
  adb_database_cpu_core_count           = var.atp_cpu_core_count
  adb_database_data_storage_size_in_tbs = var.atp_data_storage_size_in_tbs
  adb_database_db_name                  = var.atp_db_name
  adb_database_db_version               = var.atp_db_version
  adb_database_freeform_tags            = var.atp_freeform_tags
  adb_database_license_model            = var.atp_license_model
  adb_database_db_workload              = "OLTP"
  adb_free_tier                         = var.atp_free_tier
  use_existing_vcn                      = var.atp_private_endpoint
  adb_private_endpoint                  = var.atp_private_endpoint
  vcn_id                                = var.atp_private_endpoint ? oci_core_vcn.vcn01.id : null
  adb_nsg_id                            = var.atp_private_endpoint ? oci_core_network_security_group.ATPSecurityGroup.id : null
  adb_private_endpoint_label            = var.atp_private_endpoint ? var.atp_private_endpoint_label : null
  adb_subnet_id                         = var.atp_private_endpoint ? oci_core_subnet.vcn01_subnet_db01.id : null
  defined_tags                          = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
