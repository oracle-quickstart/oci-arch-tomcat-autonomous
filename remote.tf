## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "tomcat_template1" {
  template = file("./scripts/tomcat1_bootstrap.sh")
  vars = {
    db_name              = var.ATP_database_db_name
    db_user_name         = var.ATP_username
    db_user_password     = var.ATP_password
    tde_wallet_zip_file  = var.ATP_tde_wallet_zip_file
  }
}

data "template_file" "tomcat_template2" {
  template = file("./scripts/tomcat2_bootstrap.sh")
  vars = {
    db_name              = var.ATP_database_db_name
    db_user_name         = var.ATP_username
    db_user_password     = var.ATP_password
    tde_wallet_zip_file  = var.ATP_tde_wallet_zip_file
  }
}

data "template_file" "tomcat_context_xml" {
  template = file("./java/context.xml")
  vars = {
    db_name              = var.ATP_database_db_name
    db_user_name         = var.ATP_username
    db_user_password     = var.ATP_password
  }
}


resource "null_resource" "tomcat1_bootstrap" {
  depends_on = [oci_core_instance.tomcat-server1]


  provisioner "local-exec" {
    command = "echo '${oci_database_autonomous_database_wallet.ATP_database_wallet.content}' >> ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.ATP_tde_wallet_zip_file}_encoded > ${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server1_primaryvnic.private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/tmp/${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server1_primaryvnic.private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.tomcat_template1.rendered
    destination = "/home/opc/tomcat1_bootstrap.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server1_primaryvnic.private_ip_address
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
      host        = data.oci_core_vnic.tomcat-server1_primaryvnic.private_ip_address
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
     "chmod +x ~/tomcat1_bootstrap.sh",
     "sudo ~/tomcat1_bootstrap.sh"
    ]
  }
}

resource "null_resource" "tomcat2_bootstrap" {
  depends_on = [oci_core_instance.tomcat-server2, null_resource.tomcat1_bootstrap]

  provisioner "local-exec" {
    command = "echo '${oci_database_autonomous_database_wallet.ATP_database_wallet.content}' >> ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "local-exec" {
    command = "base64 --decode ${var.ATP_tde_wallet_zip_file}_encoded > ${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.ATP_tde_wallet_zip_file}_encoded"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server2_primaryvnic.private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/tmp/${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server2_primaryvnic.private_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_instance.bastion_instance.public_ip
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.tomcat_template2.rendered
    destination = "~/tomcat2_bootstrap.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.tomcat-server2_primaryvnic.private_ip_address
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
      host        = data.oci_core_vnic.tomcat-server2_primaryvnic.private_ip_address
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
      "chmod +x ~/tomcat2_bootstrap.sh",
      "sudo ~/tomcat2_bootstrap.sh"
    ]
  }
}