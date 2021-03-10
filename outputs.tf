output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}

output "todoapp_url" {
  value = "http://${oci_load_balancer.lb01.ip_addresses[0]}/todoapp/list"
}

output "bastion_public_ip" {
  value = oci_core_instance.bastion_instance.public_ip
}

output "tomcat1-server_private_ip" {
  value = data.oci_core_vnic.tomcat-server1_primaryvnic.private_ip_address
}

output "tomcat2-server_private_ip" {
  value = data.oci_core_vnic.tomcat-server2_primaryvnic.private_ip_address
}