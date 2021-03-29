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

