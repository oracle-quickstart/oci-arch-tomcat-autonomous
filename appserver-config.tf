# Copyright (c) 2020, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "Webserver1_ConfigMgmt" {
  depends_on = [oci_core_instance.webserver1, oci_database_autonomous_database.ATPdatabase]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic.public_ip_address
      private_key = file(var.ssh_private_key)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
    "sudo yum update -y",
    "sudo yum install -y tomcat",
    "sudo yum install -y git",
    "sudo yum install -y ant",
    "mkdir ~/ojdbc",
    "cd ~/ojdbc",
    "curl -O https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc10/19.6.0.0/ojdbc10-19.6.0.0.jar",
    "curl -O https://repo1.maven.org/maven2/com/oracle/database/jdbc/ucp/19.6.0.0/ucp-19.6.0.0.jar",
    "curl -O https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.6.0.0/ojdbc8-19.6.0.0.jar",
    "curl -O https://repo1.maven.org/maven2/com/oracle/database/security/osdt_core/19.6.0.0/osdt_core-19.6.0.0.jar",
    "curl -O https://repo1.maven.org/maven2/com/oracle/database/security/osdt_cert/19.6.0.0/osdt_cert-19.6.0.0.jar",
    "curl -O https://repo1.maven.org/maven2/com/oracle/database/security/oraclepki/19.6.0.0/oraclepki-19.6.0.0.jar",
    "sudo firewall-cmd --add-port=8080/tcp --permanent",
    "sudo firewall-cmd --reload",
    "sudo systemctl enable --now tomcat",
    "cd ~",
    "curl -L -b \"oraclelicense=a\" -O https://download.oracle.com/otn-pub/java/jdk/14.0.1+7/664493ef4a6946b186ff29eb326336a2/jdk-14.0.1_linux-x64_bin.rpm",
    "sudo yum localinstall -y jdk-14.0.1_linux-x64_bin.rpm",
    "git clone https://github.com/oracle/oracle-db-examples.git"
    # "mkdir ~/oracle-db-examples/java/jdbc/Tomcat_Servlet/META-INF/"
    ]
  }

provisioner "local-exec" {
    command = "sed -i -e s@XXXXXXXX@'${random_string.wallet_password.result}'@ context.xml"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic.public_ip_address
      private_key = file(var.ssh_private_key)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "context.xml"
    destination = "~/oracle-db-examples/java/jdbc/Tomcat_Servlet/META-INF/context.xml"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic.public_ip_address
      private_key = file(var.ssh_private_key)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "build.xml"
    destination = "~/oracle-db-examples/java/jdbc/Tomcat_Servlet/build.xml"
    # destination = "build.xml"
  }

  provisioner "local-exec" {
    command = "echo '${data.oci_database_autonomous_database_wallet.ATP_database_wallet.content}' >> ${var.ATP_tde_wallet_zip_file}_encoded"
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
      host        = data.oci_core_vnic.webserver1_primaryvnic.public_ip_address
      private_key = file(var.ssh_private_key)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/home/opc/${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic.public_ip_address
      private_key = file(var.ssh_private_key)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 4. Unzip TDE wallet zip file'",
      "sudo mkdir /etc/tomcat/wallet",
      "sudo unzip -o /home/opc/${var.ATP_tde_wallet_zip_file} -d /etc/tomcat/wallet"]
  }

 }

resource "null_resource" "Webserver1_TOmcat_Build" {
  depends_on = [null_resource.Webserver1_ConfigMgmt]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic.public_ip_address
      private_key = file(var.ssh_private_key)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "cd ~/oracle-db-examples/java/jdbc/Tomcat_Servlet",
      # "cp -fv ~/build.xml ~/oracle-db-examples/java/jdbc/Tomcat_Servlet/build.xml",
      "mkdir -p /home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/WEB-INF/lib",
      "cp -v ~/ojdbc/* /home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/WEB-INF/lib/",
      "ant",
      "sudo cp /home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/dist/JDBCSample.war /usr/share/tomcat/webapps/",
      "sudo systemctl restart tomcat"
    ]
  }

}