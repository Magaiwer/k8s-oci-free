# network/outputs.tf
output "vcn_id" {
  description = "OCID da VCN criada"
  value       = oci_core_vcn.oke_vcn.id
}

output "api_subnet_id" {
  description = "OCID da Subnet do Control Plane (API Endpoint)"
  value       = oci_core_subnet.oke_api_subnet.id
}

output "nodes_subnet_id" {
  description = "OCID da Subnet dos Worker Nodes"
  value       = oci_core_subnet.oke_nodes_subnet.id
}
