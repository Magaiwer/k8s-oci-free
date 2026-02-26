# modules/addons/variables.tf

variable "enable_headlamp" {
  description = "Instala o painel leve Headlamp no cluster OKE"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Instala a stack Kube-Prometheus (Prometheus + Grafana)"
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "Instala o Loki (Logs) e OpenTelemetry Collector"
  type        = bool
  default     = false
}
