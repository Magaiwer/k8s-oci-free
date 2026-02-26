# network/variables.tf
variable "compartment_id" {
  description = "OCID do Compartimento onde a rede será criada"
  type        = string
}

variable "cluster_name" {
  description = "Nome do Cluster OKE (usado como prefixo para os recursos)"
  type        = string
}

variable "vcn_cidr_blocks" {
  description = "Lista de blocos CIDR para a VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "api_subnet_cidr" {
  description = "Bloco CIDR para a subnet do Control Plane (Endpoint da API K8s)"
  type        = string
  default     = "10.0.1.0/28"
}

variable "nodes_subnet_cidr" {
  description = "Bloco CIDR para a subnet dos Worker Nodes"
  type        = string
  default     = "10.0.2.0/24"
}
