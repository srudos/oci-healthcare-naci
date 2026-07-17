############################################################
# Outputs (infra)
############################################################

output "oke_cluster_id" {
  value = oci_containerengine_cluster.oke.id
}

output "oke_node_pool_id" {
  value = oci_containerengine_node_pool.node_pool.id
}

output "postgres_primary_fqdn" {
  value = data.oci_psql_db_system_connection_detail.psql_conn.primary_db_endpoint[0].fqdn
}

output "postgres_primary_port" {
  value = data.oci_psql_db_system_connection_detail.psql_conn.primary_db_endpoint[0].port
}

output "public_test_vm_ip" {
  description = "Public IP of the Oracle Linux VM"
  value       = oci_core_instance.test_vm.public_ip
}
