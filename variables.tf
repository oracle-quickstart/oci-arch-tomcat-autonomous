## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.4"
}

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "fingerprint" {}
variable "user_ocid" {}
variable "private_key_path" {}
variable "availablity_domain_name" {}
variable "atp_password" {}

variable "ssh_public_key" {
  default = ""
}

variable "use_bastion_service" {
  default = false
}

variable "igw_display_name" {
  default = "internet-gateway"
}

variable "vcn01_cidr_block" {
  default = "10.0.0.0/16"
}
variable "vcn01_dns_label" {
  default = "vcn01"
}
variable "vcn01_display_name" {
  default = "vcn01"
}

variable "vcn01_subnet_pub01_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vcn01_subnet_pub01_display_name" {
  default = "vcn01_subnet_pub01"
}

variable "vcn01_subnet_pub02_cidr_block" {
  default = "10.0.2.0/24"
}

variable "vcn01_subnet_pub02_display_name" {
  default = "vcn01_subnet_pub02"
}

variable "vcn01_subnet_app01_cidr_block" {
  default = "10.0.10.0/24"
}

variable "vcn01_subnet_app01_display_name" {
  default = "vcn01_subnet_app01"
}

variable "vcn01_subnet_db01_cidr_block" {
  default = "10.0.20.0/24"
}

variable "vcn01_subnet_db01_display_name" {
  default = "vcn01_subnet_db01"
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "InstanceShape" {
  default = "VM.Standard.A1.Flex"
}

variable "InstanceFlexShapeOCPUS" {
  default = 1
}

variable "InstanceFlexShapeMemory" {
  default = 10
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

variable "numberOfNodes" {
  default = 2
}

variable "oracle_instant_client_version" {
  #  default     = "21.1"
  default = "19.10"
}

variable "oracle_instant_client_version_short" {
  #  default     = "21"
  default = "19.10"
}

variable "tomcat_version" {
  default = "9.0.45"
}

variable "atp_private_endpoint" {
  default = true
}

variable "atp_username" {
  default = "todoapp"
}

variable "atp_cpu_core_count" {
  default = 1
}

variable "atp_free_tier" {
  default = true
}

variable "atp_data_storage_size_in_tbs" {
  default = 1
}

variable "atp_db_name" {
  default = "ATPDB"
}

variable "atp_db_version" {
  default = "19c"
}

variable "atp_defined_tags_value" {
  default = ""
}

variable "atp_name" {
  default = "TomcatATP"
}

variable "atp_freeform_tags" {
  default = {
    "Owner" = "ATP"
  }
}

variable "atp_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "atp_tde_wallet_zip_file" {
  default = "tde_wallet_ATPdb1.zip"
}

variable "atp_private_endpoint_label" {
  default = "ATPPrivateEndpoint"
}


