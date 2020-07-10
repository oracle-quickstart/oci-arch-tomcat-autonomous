## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_instance" "webserver1" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[1]["name"]
  compartment_id = var.compartment_ocid
  display_name = "tomcat01"
  shape = var.InstanceShape

  create_vnic_details {
    subnet_id = oci_core_subnet.vcn01_subnet_app01.id
    display_name = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  # timeouts {
  #   create = "60m"
  # }
}

data "oci_core_vnic_attachments" "webserver1_primaryvnic_attach" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name")
  compartment_id = var.compartment_ocid
  instance_id         = oci_core_instance.webserver1.id
}

data "oci_core_vnic" "webserver1_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.webserver1_primaryvnic_attach.vnic_attachments.0.vnic_id
}

output "webserver1_PublicIP" {
  value = [data.oci_core_vnic.webserver1_primaryvnic.public_ip_address]
}