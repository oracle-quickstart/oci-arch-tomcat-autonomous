## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_instance" "bastion_instance" {
  availability_domain = var.availablity_domain_name
  compartment_id = var.compartment_ocid
  display_name = "BastionVM"
  shape = var.InstanceShape

  create_vnic_details {
    subnet_id = oci_core_subnet.vcn01_subnet_pub02.id
    display_name = "primaryvnic"
    assign_public_ip = true
    nsg_ids = [oci_core_network_security_group.SSHSecurityGroup.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_instance" "tomcat-server1" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "tomcat-server1"
  shape               = var.InstanceShape

  create_vnic_details {
    subnet_id = oci_core_subnet.vcn01_subnet_app01.id
    display_name = "primaryvnic"
    assign_public_ip = false
    nsg_ids = [oci_core_network_security_group.SSHSecurityGroup.id, oci_core_network_security_group.APPSecurityGroup.id]
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_instance" "tomcat-server2" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "tomcat-server2"
  shape               = var.InstanceShape

  create_vnic_details {
    subnet_id = oci_core_subnet.vcn01_subnet_app01.id
    display_name = "primaryvnic"
    assign_public_ip = false
    nsg_ids = [oci_core_network_security_group.SSHSecurityGroup.id, oci_core_network_security_group.APPSecurityGroup.id]
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

