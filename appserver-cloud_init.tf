## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "key_script" {
  template = "${file("./templates/sshkey.tpl")}"
  vars = {
    "ssh_public_key" = "${tls_private_key.opc_key.public_key_openssh}"
  }
}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "app_server_cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.key_script.rendered}"
  }

}
