# modules/addons/main.tf

# -----------------
# 1. Kube-Prometheus-Stack (Prometheus, Grafana, Alertmanager)
# -----------------
resource "helm_release" "kube_prometheus_stack" {
  count            = var.enable_monitoring ? 1 : 0
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "68.2.1"

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "512Mi"
  }
  set {
    name  = "prometheus.prometheusSpec.resources.limits.memory"
    value = "1024Mi"
  }
}

# -----------------
# 2. Headlamp (Painel Gráfico Leve)
# -----------------
resource "helm_release" "headlamp" {
  count            = var.enable_headlamp ? 1 : 0
  name             = "headlamp"
  repository       = "https://headlamp-k8s.github.io/headlamp/"
  chart            = "headlamp"
  namespace        = "kube-system"
  create_namespace = true
  version          = "0.28.0"

  set {
    name  = "service.type"
    value = "NodePort"
  }
}

# -----------------
# 3. Loki (Centralização de Logs Gratuito)
# -----------------
resource "helm_release" "loki" {
  count            = var.enable_telemetry ? 1 : 0
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "2.10.2"

  set {
    name  = "promtail.enabled"
    value = "true" # Coleta nativa nos pods
  }
}

# -----------------
# 4. OpenTelemetry Collector
# -----------------
resource "helm_release" "opentelemetry" {
  count            = var.enable_telemetry ? 1 : 0
  name             = "opentelemetry-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  namespace        = "monitoring"
  create_namespace = true
  version          = "0.113.1"

  set {
    name  = "mode"
    value = "daemonset"
  }
}
