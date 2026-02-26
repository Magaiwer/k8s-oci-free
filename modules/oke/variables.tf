# oke/variables.tf
variable "compartment_id" {
  description = "OCID do Compartimento"
  type        = string
}

variable "cluster_name" {
  description = "Nome do Cluster"
  type        = string
}

variable "vcn_id" {
  description = "OCID da VCN"
  type        = string
}

variable "api_subnet_id" {
  description = "OCID da Subnet do Endpoint da API Master"
  type        = string
}

variable "nodes_subnet_id" {
  description = "OCID da Subnet dos Worker Nodes"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes suportada pelo OKE"
  type        = string
}

variable "availability_domain" {
  description = "Dominio de Disponibilidade (Availability Domain) dentro da Região OCI (Ex: tYvX:US-ASHBURN-AD-1)"
  type        = string
}
