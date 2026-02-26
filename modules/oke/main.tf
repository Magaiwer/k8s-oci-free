# oke/main.tf

# -----------------
# Cluster OKE
# -----------------
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id

  # Configuração obrigatória para Always Free (O tipo deve ser BASIC_CLUSTER)
  type = "BASIC_CLUSTER"

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.api_subnet_id
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    admission_controller_options {
      is_pod_security_policy_enabled = false
    }
    service_lb_subnet_ids = []
  }
}

# -----------------
# Obtenção da Imagem Oracle Linux mais recente para o Node Pool
# -----------------
data "oci_core_images" "oracle_linux_image" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# -----------------
# Node Pool (Workers)
# -----------------
resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-pool"

  # Shape do Always Free ARM
  node_shape = "VM.Standard.A1.Flex"

  # Configuração Flex para ajustar CPU e Memória (2 Nodes x 2 OCPUs, 12GB RAM)
  node_shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  node_source_details {
    image_id    = data.oci_core_images.oracle_linux_image.images[0].id
    source_type = "IMAGE"
  }

  node_config_details {
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.nodes_subnet_id
    }
    # Mantemos 2 nodes para estourar perfeitamente o limite de 4 OCPUs e 24GB do Always Free
    size = 2
  }
}
