output "kubeconfig_command" {
  description = "Comando OCI CLI para gerar o kubeconfig e conectar no cluster."
  value       = "oci ce cluster create-kubeconfig --cluster-id ${module.oke.cluster_id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT"
}

output "cluster_id" {
  value = module.oke.cluster_id
}

output "node_pool_id" {
  value = module.oke.node_pool_id
}
