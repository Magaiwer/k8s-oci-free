# oke/outputs.tf

output "cluster_id" {
  description = "OCID do Cluster OKE"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "node_pool_id" {
  description = "OCID do Node Pool"
  value       = oci_containerengine_node_pool.oke_node_pool.id
}
