#!/bin/bash

# Install Java JDK
yum install -y jdk

# Install Tomcat
yum install -y tomcat
yum install -y tomcat-webapps 
yum install -y tomcat-admin-webapps

#I nstall Oracle instant client
yum -y install oracle-release-el7
yum-config-manager --enable ol7_oracle_instantclient
yum -y install oracle-instantclient18.3-basic
yum -y install oracle-instantclient18.3-sqlplus

# Prepare TDE wallet 
unzip -o /tmp/${tde_wallet_zip_file} -d /usr/lib/oracle/18.3/client64/lib/network/admin/

export tomcat_host='${tomcat_host}'

if [[ $tomcat_host == "tomcat-server-0" ]]; then
	# Create TODOAPP user in ATP
	rm -rf /tmp/create_todoapp_user.sql
	echo 'CREATE USER ${db_user_name} IDENTIFIED BY "${db_user_password}";' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT CREATE SESSION TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT CREATE TABLE TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT CREATE SEQUENCE TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'GRANT UNLIMITED TABLESPACE TO ${db_user_name};' | sudo tee -a /tmp/create_todoapp_user.sql
	echo 'exit;' | sudo tee -a /tmp/create_todoapp_user.sql
	export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib
	/usr/lib/oracle/18.3/client64/bin/sqlplus admin/${db_user_password}@${db_name}_medium @/tmp/create_todoapp_user.sql > /tmp/create_todoapp_user.log
	cat /tmp/create_todoapp_user.log
	# Create TODOS table in ATP
	rm -rf /tmp/create_todos_table.sql
	echo 'CREATE TABLE TODOS (' | sudo tee -a /tmp/create_todos_table.sql
	echo 'id number GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),' | sudo tee -a /tmp/create_todos_table.sql 
	echo 'title varchar2(255),' | sudo tee -a /tmp/create_todos_table.sql
	echo 'description varchar2(255),' | sudo tee -a /tmp/create_todos_table.sql
	echo "is_done char(1) check (is_done in ('Y','N'))" | sudo tee -a /tmp/create_todos_table.sql 
	echo ');' | sudo tee -a /tmp/create_todos_table.sql
	echo 'SELECT * FROM TODOS;' | sudo tee -a /tmp/create_todos_table.sql
	echo 'exit;' | sudo tee -a /tmp/create_todos_table.sql
	export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib
	/usr/lib/oracle/18.3/client64/bin/sqlplus ${db_user_name}/${db_user_password}@${db_name}_medium @/tmp/create_todos_table.sql > /tmp/create_todos_table.log
	cat /tmp/create_todos_table.log
fi

# Prepare application and Tomcat
cp /home/opc/context.xml /etc/tomcat/context.xml
curl https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/18.3.0.0/ojdbc8-18.3.0.0.jar -o /home/opc/ojdbc8-18.3.0.0.jar
curl https://repo1.maven.org/maven2/com/oracle/database/jdbc/ucp/18.3.0.0/ucp-18.3.0.0.jar -o /home/opc/ucp-18.3.0.0.jar
cp /home/opc/ojdbc8-18.3.0.0.jar /usr/share/tomcat/lib/
cp /home/opc/ucp-18.3.0.0.jar /usr/share/tomcat/lib/

# Start Tomcat
setsebool -P tomcat_can_network_connect_db 1
systemctl start tomcat
systemctl status tomcat
systemctl enable tomcat
wget -O /home/opc/todoapp.war https://github.com/oracle-quickstart/oci-arch-tomcat-autonomous/releases/latest/download/todoapp-atp.war
chown opc:opc /home/opc/todoapp.war
cp /home/opc/todoapp.war /usr/share/tomcat/webapps/
sleep 30
cp /usr/share/tomcat/lib/ojdbc8-18.3.0.0.jar /usr/share/tomcat/webapps/todoapp/WEB-INF/lib
cp /usr/share/tomcat/lib/ucp-18.3.0.0.jar /usr/share/tomcat/webapps/todoapp/WEB-INF/lib
systemctl stop tomcat
systemctl start tomcat

service firewalld stop
systemctl disable firewalld




