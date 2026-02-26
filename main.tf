module "network" {
  source = "./modules/network"

  compartment_id    = var.compartment_id
  cluster_name      = var.cluster_name
  vcn_cidr_blocks   = var.vcn_cidr_blocks
  api_subnet_cidr   = var.api_subnet_cidr
  nodes_subnet_cidr = var.nodes_subnet_cidr
}

module "oke" {
  source = "./modules/oke"

  compartment_id      = var.compartment_id
  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  availability_domain = var.availability_domain

  # Inputs que vêm como Outputs do módulo de rede
  vcn_id          = module.network.vcn_id
  api_subnet_id   = module.network.api_subnet_id
  nodes_subnet_id = module.network.nodes_subnet_id
}

module "addons" {
  source = "./modules/addons"

  enable_headlamp   = var.enable_headlamp
  enable_monitoring = var.enable_monitoring
  enable_telemetry  = var.enable_telemetry

  # A dependência explícita garante que os helm charts só rodem após o cluster existir
  depends_on = [module.oke]
}
