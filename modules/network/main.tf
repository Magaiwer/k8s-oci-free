# network/main.tf
# Criação da Virtual Cloud Network (VCN)
resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_id
  display_name   = "${var.cluster_name}-vcn"
  cidr_blocks    = var.vcn_cidr_blocks
  dns_label      = "okevcn"
}

# Internet Gateway para acesso público aos nós e API Mestra
resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-igw"
  enabled        = true
}

# Tabela de roteamento pública associando ao Internet Gateway
resource "oci_core_route_table" "oke_public_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

# ---------------
# Módulo de Segurança (Security Lists Simplificadas para Always Free "KISS")
# ---------------

# Security List para a Subnet de Nodes (onde os pods/serviços rodam)
resource "oci_core_security_list" "oke_nodes_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-nodes-sl"

  # Egress liberado para baixar imagens e comunicar com a internet
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Ingress liberado para tráfego interno da VCN (Pods conversando entre si)
  ingress_security_rules {
    protocol = "all"
    source   = oci_core_vcn.oke_vcn.cidr_blocks[0]
  }

  # Ingress liberado para NodePorts (Padrão 30000-32767)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # Acesso SSH opcional
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

# Security List para o Kubernetes API Endpoint
resource "oci_core_security_list" "oke_api_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-api-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # Acesso interno na VCN
  ingress_security_rules {
    protocol = "all"
    source   = oci_core_vcn.oke_vcn.cidr_blocks[0]
  }
}

# ---------------
# Subnets
# ---------------

# Subnet Pública para a API do Control Plane
resource "oci_core_subnet" "oke_api_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.api_subnet_cidr
  display_name               = "${var.cluster_name}-api-subnet"
  route_table_id             = oci_core_route_table.oke_public_rt.id
  security_list_ids          = [oci_core_security_list.oke_api_sl.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = "api"
}

# Subnet Pública para os works (Nodes)
# Usando public subnet no Always Free evita a criação de NAT Gateways custosos ou complexos.
resource "oci_core_subnet" "oke_nodes_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.nodes_subnet_cidr
  display_name               = "${var.cluster_name}-nodes-subnet"
  route_table_id             = oci_core_route_table.oke_public_rt.id
  security_list_ids          = [oci_core_security_list.oke_nodes_sl.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = "nodes"
}
