## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Checks if is using Flexible LB Shapes
locals {
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}

resource "oci_load_balancer" "lb01" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.vcn01_subnet_pub01.id,
  ]

  display_name               = "load_balancer_01"
  network_security_group_ids = [oci_core_network_security_group.LBSecurityGroup.id]

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_load_balancer_backend_set" "lb_be_app01" {
  name             = "lb_app01"
  load_balancer_id = oci_load_balancer.lb01.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "8080"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_listener_app01" {
  load_balancer_id         = oci_load_balancer.lb01.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb_be_app01.name
  port                     = 80
  protocol                 = "HTTP"

}

resource "oci_load_balancer_backend" "lb_be_tomcat" {
  count            = var.numberOfNodes
  load_balancer_id = oci_load_balancer.lb01.id
  backendset_name  = oci_load_balancer_backend_set.lb_be_app01.name
  ip_address       = oci_core_instance.tomcat-server[count.index].private_ip
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
