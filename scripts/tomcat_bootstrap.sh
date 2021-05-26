#!/bin/bash

# Install Java JDK & Tomcat
echo '== 1. Install Java JDK & Tomcat'
yum install -y jdk

useradd tomcat

mkdir /u01
wget -O /u01/apache-tomcat-${tomcat_version}.zip https://archive.apache.org/dist/tomcat/tomcat-${tomcat_major_release}/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.zip
unzip /u01/apache-tomcat-${tomcat_version}.zip -d /u01/
chown -R tomcat:tomcat /u01
chmod +x /u01/apache-tomcat-${tomcat_version}/bin/*.sh

# Install Oracle instant client

echo '== 2. Install Oracle instant client'
if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then 
  if [[ $(uname -m | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "aarch64" ]]
  then
    echo '=== 2.1 aarch64 platform & OL8' 
  	yum install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient19.10-basic-19.10.0.0.0-1.aarch64.rpm
  	yum install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient19.10-sqlplus-19.10.0.0.0-1.aarch64.rpm
  else
  	echo '=== 2.1 x86_64 platform & OL8'
    dnf install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64.rpm
    dnf install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.10-sqlplus-19.10.0.0.0-1.x86_64.rpm
  fi	
else
  if [[ $(uname -m | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "aarch64" ]]
  then 	
  	echo '=== 2.1 aarch64 platform & OL7' 
  	yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/aarch64/getPackage/oracle-instantclient19.10-basic-19.10.0.0.0-1.aarch64.rpm
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/aarch64/getPackage/oracle-instantclient19.10-sqlplus-19.10.0.0.0-1.aarch64.rpm
  else
    echo '=== 2.1 x86_64 platform & OL7'
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64.rpm
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient19.10-sqlplus-19.10.0.0.0-1.x86_64.rpm
  fi
fi 

# Prepare TDE wallet 
echo '== 3. Prepare TDE wallet'
unzip -o /tmp/${tde_wallet_zip_file} -d /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/

export tomcat_host='${tomcat_host}'

if [[ $tomcat_host == "tomcat-server-0" ]]; then
	# Create TODOAPP user in ATP
	echo '== 4. Create TODOAPP user in ATP'
	rm -rf /tmp/create_todoapp_user.sql
	echo 'CREATE USER ${db_user_name} IDENTIFIED BY "${db_user_password}";' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT CREATE SESSION TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT CREATE TABLE TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT CREATE SEQUENCE TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT UNLIMITED TABLESPACE TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'exit;' | sudo tee -a /tmp/create_todoapp_user.sql
	export LD_LIBRARY_PATH=/usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib
	/usr/lib/oracle/${oracle_instant_client_version_short}/client64/bin/sqlplus admin/${db_user_password}@${db_name}_medium @/tmp/create_todoapp_user.sql > /tmp/create_todoapp_user.log
	cat /tmp/create_todoapp_user.log
	# Create TODOS table in ATP
	echo '== 5. Create TODOS table in ATP'
	rm -rf /tmp/create_todos_table.sql
	echo 'CREATE TABLE TODOS (' | sudo tee -a /tmp/create_todos_table.sql
	echo 'id number GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),' | sudo tee -a /tmp/create_todos_table.sql 
	echo 'title varchar2(255),' | sudo tee -a /tmp/create_todos_table.sql
	echo 'description varchar2(255),' | sudo tee -a /tmp/create_todos_table.sql
	echo "is_done char(1) check (is_done in ('Y','N'))" | sudo tee -a /tmp/create_todos_table.sql 
	echo ');' | sudo tee -a /tmp/create_todos_table.sql
	echo 'SELECT * FROM TODOS;' | sudo tee -a /tmp/create_todos_table.sql
	echo 'exit;' | sudo tee -a /tmp/create_todos_table.sql
	export LD_LIBRARY_PATH=/usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib
	/usr/lib/oracle/${oracle_instant_client_version_short}/client64/bin/sqlplus ${db_user_name}/${db_user_password}@${db_name}_medium @/tmp/create_todos_table.sql > /tmp/create_todos_table.log
	cat /tmp/create_todos_table.log
fi

# Prepare application and Tomcat
echo '== 6. Prepare application and Tomcat'
cp /home/opc/context.xml /u01/apache-tomcat-${tomcat_version}/conf/context.xml

# Start Tomcat
echo '== 7. Start Tomcat'
setsebool -P tomcat_can_network_connect_db 1
chmod +x /u01/apache-tomcat-${tomcat_version}/bin/*.sh
sudo -u tomcat nohup /u01/apache-tomcat-${tomcat_version}/bin/startup.sh &

# Download TODOAPP and deploy in Tomcat
echo '== 8. Download TODOAPP and deploy in Tomcat'
wget -O /home/opc/todoapp.war https://github.com/oracle-quickstart/oci-arch-tomcat-autonomous/releases/latest/download/todoapp-atp.war
chown opc:opc /home/opc/todoapp.war
cp /home/opc/todoapp.war /u01/apache-tomcat-${tomcat_version}/webapps
chown tomcat:tomcat /u01/apache-tomcat-${tomcat_version}/webapps/todoapp.war
sleep 30

# Adding Tomcat as systemd service
echo '== 9. Adding Tomcat as systemd service'
cp /home/opc/tomcat.service /etc/systemd/system/
ls -latr /etc/systemd/system/tomcat.service
chown root:root /etc/systemd/system/tomcat.service
cat /etc/systemd/system/tomcat.service
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat
sleep 20
ps -ef | grep tomcat

# Stop and disable firewalld 
echo '== 10. Stop and disable firewalld '
service firewalld stop
systemctl disable firewalld


