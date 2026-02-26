variable "tenancy_ocid" {
  description = "OCID da Tenancy OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID do Usuário OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da chave da API do usuário"
  type        = string
}

variable "private_key_path" {
  description = "Caminho do sistema local para a chave privada da API (.pem)"
  type        = string
}

variable "region" {
  description = "Região OCI (Ex: us-ashburn-1)"
  type        = string
}

variable "compartment_id" {
  description = "OCID do Compartimento para criação dos recursos"
  type        = string
}

variable "cluster_name" {
  description = "Nome do Cluster OKE"
  type        = string
  default     = "k8s-always-free"
}

variable "kubernetes_version" {
  description = "Versão do K8s (Verifique as versões limitadas suportadas pelo seu tenant)"
  type        = string
  default     = "v1.31.1" # Recomendado checar a versão exata mais recente via CLI `oci ce cluster-options get --compartment-id...`
}

variable "availability_domain" {
  description = "Dominio de Disponibilidade dentro da Região OCI (Ex: tYvX:US-ASHBURN-AD-1)"
  type        = string
}

# Variáveis de Rede Opcionais com valores default
variable "vcn_cidr_blocks" {
  description = "Blocos CIDR da VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "api_subnet_cidr" {
  description = "Subnet do API Endpoint K8s"
  type        = string
  default     = "10.0.1.0/28"
}

variable "nodes_subnet_cidr" {
  description = "Subnet dos Node Pools"
  type        = string
  default     = "10.0.2.0/24"
}

# -----------------
# Variáveis de Configuração Opcionais (Add-ons via Helm)
# -----------------
variable "enable_headlamp" {
  description = "Habilitar a instalação do painel Headlamp no cluster OKE."
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Habilitar a instalação da Stack Kube-Prometheus (Prometheus + Grafana)."
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "Habilitar a instalação do Loki (Logs) e OpenTelemetry Collector."
  type        = bool
  default     = false
}
