## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn01" {
  cidr_block     = var.vcn01_cidr_block
  dns_label      = var.vcn01_dns_label
  compartment_id = var.compartment_ocid
  display_name   = var.vcn01_display_name
}

#IGW
resource "oci_core_internet_gateway" "vcn01_internet_gateway" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn01.id
    enabled = "true"
    display_name = "IGW_vcn01"
}

resource "oci_core_nat_gateway" "vcn01_nat_gateway" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn01.id
    display_name = "NAT_GW_vcn01"
}

#Default route table vcn01
resource "oci_core_default_route_table" "vcn01_default_route_table" {
    manage_default_resource_id = oci_core_vcn.vcn01.default_route_table_id
    route_rules {
        network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway.id
        destination       = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
    }    
}

#Default security list
resource "oci_core_default_security_list" "vcn01_default_security_list" {
    manage_default_resource_id = oci_core_vcn.vcn01.default_security_list_id
    egress_security_rules {
        destination = "0.0.0.0/0"
        protocol = "all"
    }
    ingress_security_rules {
        protocol = 6
        source = "0.0.0.0/0"

        source_type = "CIDR_BLOCK"
        tcp_options {
            max = 22
            min = 22
        }
    }
    ingress_security_rules {
        protocol = 6
        source = "0.0.0.0/0"

        source_type = "CIDR_BLOCK"
        tcp_options {
            max = 80
            min = 80
        }
    }
    ingress_security_rules {
        protocol = 6
        source = "0.0.0.0/0"

        source_type = "CIDR_BLOCK"
        tcp_options {
            max = 8080
            min = 8080
        }
    }
             
}

resource "oci_core_network_security_group" "ATPSecurityGroup" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn01.id
    display_name = "DB_NSG"
}

resource "oci_core_network_security_group_security_rule" "ATPSecurityIngressGroupRules" {
    network_security_group_id = oci_core_network_security_group.ATPSecurityGroup.id
    direction = "INGRESS"
    protocol = "6"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = 1521
            min = 1521
        }
    }
}


resource "oci_core_route_table" "vnc01_nat_route_table" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn01.id
    route_rules {
        network_entity_id = oci_core_nat_gateway.vcn01_nat_gateway.id
        cidr_block = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}


#vcn01 pub subnet
resource "oci_core_subnet" "vcn01_subnet_pub01" {
    cidr_block = var.vcn01_subnet_pub01_cidr_block
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn01.id
    display_name = var.vcn01_subnet_pub01_display_name
}

#vcn01 app01 subnet
resource "oci_core_subnet" "vcn01_subnet_app01" {
    cidr_block = var.vcn01_subnet_app01_cidr_block
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn01.id
    display_name = var.vcn01_subnet_app01_display_name
}
# resource "oci_core_route_table_attachment" "vcn01_subnet_app01_route_table_attachment" {
#   subnet_id = oci_core_subnet.vcn01_subnet_app01.id
#   route_table_id = oci_core_route_table.vnc01_nat_route_table.id
# }


#vcn01 db01 subnet
resource "oci_core_subnet" "vcn01_subnet_db01" {
    cidr_block = var.vcn01_subnet_db01_cidr_block
    compartment_id = var.compartment_ocid
    dns_label = "dbsubnet"
    vcn_id = oci_core_vcn.vcn01.id
    display_name = var.vcn01_subnet_db01_display_name
}
resource "oci_core_route_table_attachment" "vcn01_subnet_db01_route_table_attachment" {
  subnet_id = oci_core_subnet.vcn01_subnet_db01.id
  route_table_id = oci_core_route_table.vnc01_nat_route_table.id
}


# Bastion VM

# resource "oci_core_instance" "bastion_instance" {
#   availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[1]["name"]
#   compartment_id = var.compartment_ocid
#   display_name = "BastionVM"
#   shape = var.InstanceShape

#   create_vnic_details {
#     subnet_id = oci_core_subnet.vcn01_subnet_pub01.id
#     display_name = "primaryvnic"
#     assign_public_ip = true
#   }

#   source_details {
#     source_type             = "image"
#     source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
#     boot_volume_size_in_gbs = "50"
#   }

#   metadata = {
#     ssh_authorized_keys = var.ssh_public_key
#   }
#   # timeouts {
#   #   create = "60m"
#   # }
# }