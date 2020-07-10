## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_autonomous_database" "ATPdatabase" {
    admin_password = var.atp_password
    compartment_id = var.compartment_ocid
    cpu_core_count = 1
    data_storage_size_in_tbs = 1
    db_name = var.atp_db_name
    # data_safe_status = var.autonomous_database_data_safe_status
    # db_workload = var.autonomous_database_db_workload
    display_name = "tomcat"
    is_auto_scaling_enabled = false
    # license_model = var.autonomous_database_license_model
    nsg_ids = [oci_core_network_security_group.ATPSecurityGroup.id]
    subnet_id = oci_core_subnet.vcn01_subnet_db01.id
}