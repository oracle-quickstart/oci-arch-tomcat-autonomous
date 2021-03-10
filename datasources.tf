## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Get list of availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

#Get list of MySQL configuration
data "oci_mysql_mysql_configurations" "mds_mysql_configurations" {
    compartment_id = var.compartment_ocid

}

data "oci_core_vnic_attachments" "tomcat-server1_primaryvnic_attach" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.tomcat-server1.id
}

data "oci_core_vnic" "tomcat-server1_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.tomcat-server1_primaryvnic_attach.vnic_attachments.0.vnic_id
}


data "oci_core_vnic_attachments" "tomcat-server2_primaryvnic_attach" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.tomcat-server2.id
}

data "oci_core_vnic" "tomcat-server2_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.tomcat-server2_primaryvnic_attach.vnic_attachments.0.vnic_id
}
