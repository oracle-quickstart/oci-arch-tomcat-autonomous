## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "private_key_path" {}
variable "fingerprint" {}
variable "user_ocid" {}


variable "region" {}
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

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
  default = "10.0.0.0/24"
}

variable "vcn01_subnet_pub01_display_name" {
  default = "vcn01_subnet_pub01"
}

variable "vcn01_subnet_app01_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vcn01_subnet_app01_display_name" {
  default = "vcn01_subnet_app01"
}

variable "vcn01_subnet_db01_cidr_block" {
  default = "10.0.2.0/24"
}

variable "vcn01_subnet_db01_display_name" {
  default = "vcn01_subnet_db01"
}

variable "use_existing_network" {
  type = bool
  default = false
}





# OS Images
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.7"
}

# Defines the number of instances to deploy
variable "NumInstances" {
    default = "1"
}

variable "InstanceShape" {
    default = "VM.Standard2.1"
}

variable "InstanceImageOCID" {
    type = map(string)
    default = {
        // See https://docs.cloud.oracle.com/images/
        // Oracle-provided image "Oracle-Autonomous-Linux-7.7-2020.01-0"
        us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaasrjyeax4sznb3jxnamxrjpgiw2ked3isrmj6ktu44uso4mln7dua"
        us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaioy3pwjguhyxmp7gmfp534hmz27o7yfdt4b23qgs7ypr52k3zk5q"
    }
}

variable "ATP_tde_wallet_zip_file" {default = "tde_wallet_ATPdb1.zip"}

variable "atp_password" {}
variable "atp_db_name" {}
variable "atp_name" {} 