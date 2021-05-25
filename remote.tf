## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "tomcat_service_template" {
  count = var.numberOfNodes
  template = file("./scripts/tomcat.service")

  vars = {
    tomcat_version = var.tomcat_version
  }
}

data "template_file" "tomcat_template" {
  count = var.numberOfNodes
  
  template = file("./scripts/tomcat_bootstrap.sh")
  vars = {
    db_name                             = var.atp_db_name
    db_user_name                        = var.atp_username
    db_user_password                    = var.atp_password
    tde_wallet_zip_file                 = var.atp_tde_wallet_zip_file
    oracle_instant_client_version       = var.oracle_instant_client_version
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
    tomcat_host                         = "tomcat-server-${count.index}"
    tomcat_version                      = var.tomcat_version
    tomcat_major_release                = split(".", var.tomcat_version)[0]
  }
}

data "template_file" "tomcat_context_xml" {
  template = file("./java/context.xml")
  vars = {
    db_name                             = var.atp_db_name
    db_user_name                        = var.atp_username
    db_user_password                    = var.atp_password
    oracle_instant_client_version_short = var.oracle_instant_client_version_short
  }
}

resource "null_resource" "tomcat-server-config" {
  depends_on = [oci_core_instance.tomcat-server, oci_database_autonomous_database.ATPdatabase]
  count = var.numberOfNodes

  provisioner "local-exec" {
    command = "echo '${oci_database_autonomous_database_wallet.atp_wallet.content}' >> ${var.atp_tde_wallet_zip_file}_encoded-${count.index}"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.atp_tde_wallet_zip_file}_encoded-${count.index} > ${var.atp_tde_wallet_zip_file}-${count.index}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.atp_tde_wallet_zip_file}_encoded-${count.index}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server_primaryvnic[count.index].private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = "${var.atp_tde_wallet_zip_file}-${count.index}"
    destination = "/tmp/${var.atp_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.atp_tde_wallet_zip_file}-${count.index}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server_primaryvnic[count.index].private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.tomcat_template[count.index].rendered
    destination = "/home/opc/tomcat_bootstrap.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server_primaryvnic[count.index].private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.tomcat_service_template[count.index].rendered
    destination = "/home/opc/tomcat.service"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server_primaryvnic[count.index].private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.tomcat_context_xml.rendered
    destination = "~/context.xml"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server_primaryvnic[count.index].private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
  
    }
    inline = [
     "chmod +x ~/tomcat_bootstrap.sh",
     "sudo ~/tomcat_bootstrap.sh"
    ]
  }

}

