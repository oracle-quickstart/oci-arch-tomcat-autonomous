# Copyright (c) 2020, Oracle and/or its affiliates. 
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "Webserver1_ConfigMgmt" {
  depends_on = [oci_core_instance.webserver1, oci_database_autonomous_database.ATPdatabase]
  count = var.numberOfNodes
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic[count.index].public_ip_address
      private_key = tls_private_key.opc_key.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
    "sudo yum update -y",
    "sudo yum install -y tomcat",
    "sudo yum install -y git",
    "sudo yum install -y ant",
    "cd ~",
    "curl -LO -H 'Cookie: oraclelicense=accept-securebackup-cookie' -O https://download.oracle.com/otn-pub/otn_software/jdbc/ojdbc8-full.tar.gz",
    "sudo tar -xvf ojdbc8-full.tar.gz --strip 1 -C /usr/share/java/tomcat/",
    # this jar conflicts with the driver in same cases
    "sudo rm -f /usr/share/java/tomcat/xmlparserv2.jar",
    # other missing jar
    "sudo wget -O /usr/share/java/tomcat/tomcat-dbcp-7.0.76.jar http://search.maven.org/remotecontent?filepath=org/apache/tomcat/tomcat-dbcp/7.0.76/tomcat-dbcp-7.0.76.jar",
    "sudo firewall-cmd --add-port=8080/tcp --permanent",
    "sudo firewall-cmd --reload",
    "sudo systemctl enable --now tomcat",
    "cd ~",
    "curl -LO -H 'Cookie: oraclelicense=accept-securebackup-cookie' -O https://download.oracle.com/otn-pub/java/jdk/14.0.2+12/205943a0976c4ed48cb16f1043c5c647/jdk-14.0.2_linux-x64_bin.rpm",
    "sudo yum localinstall -y jdk-14.0.2_linux-x64_bin.rpm",
    "sudo alternatives --set java $(rpm -ql jdk-14 | grep 'bin/java$')",
    "sudo alternatives --set javac $(rpm -ql jdk-14 | grep 'bin/javac$')",
    "git clone https://github.com/oracle/oracle-db-examples.git",
    "sed -i -e s%/Users/test/apache-tomcat-9.0.0.M17%/usr/share/tomcat% ~/oracle-db-examples/java/jdbc/Tomcat_Servlet/build.xml",
    ]
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
      host        = data.oci_core_vnic.webserver1_primaryvnic[count.index].public_ip_address
      private_key = tls_private_key.opc_key.private_key_pem
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
      host        = data.oci_core_vnic.webserver1_primaryvnic[count.index].public_ip_address
      private_key = tls_private_key.opc_key.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 4. Unzip TDE wallet zip file'",
      "sudo mkdir /etc/tomcat/wallet",
      "sudo unzip -o /home/opc/${var.ATP_tde_wallet_zip_file} -d /etc/tomcat/wallet"]
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic[count.index].public_ip_address
      private_key = tls_private_key.opc_key.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "context.xml"
    destination = "/home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/META-INF/context.xml"
  }  

 }
 

resource "null_resource" "Webserver1_Tomcat_Build" {
  depends_on = [null_resource.Webserver1_ConfigMgmt]
  count = var.numberOfNodes
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.webserver1_primaryvnic[count.index].public_ip_address
      private_key = tls_private_key.opc_key.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "sed -i -e s%password.*%password='\"${var.atp_password}\"'% ~/oracle-db-examples/java/jdbc/Tomcat_Servlet/META-INF/context.xml",
      "sed -i -e s%url.*%url='\"jdbc:oracle:thin:@${var.atp_db_name}_high?TNS_ADMIN=/etc/tomcat/wallet\"'% ~/oracle-db-examples/java/jdbc/Tomcat_Servlet/META-INF/context.xml",
      "sed -i -e 's@jdbc/orcljdbc_ds@tomcat/UCP_atp@' ~/oracle-db-examples/java/jdbc/Tomcat_Servlet/src/JDBCSample_Servlet.java",
      "cd ~/oracle-db-examples/java/jdbc/Tomcat_Servlet",
      "mkdir -p /home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/WEB-INF/lib",
      # "cp -v ~/ojdbc8-full/* /home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/WEB-INF/lib/",
      "ant",
      "sudo cp /home/opc/oracle-db-examples/java/jdbc/Tomcat_Servlet/dist/JDBCSample.war /usr/share/tomcat/webapps/",
      "sudo systemctl restart tomcat"
    ]
  }

}