locals {
  # Nombres base para recursos de VPC
  base_name = "${var.client}-${var.project}-${var.environment}"

  # Nombres de recursos principales
  vpc_name                  = "${local.base_name}-vpc"
  igw_name                  = "${local.base_name}-igw"
  nat_zonal_name            = "${local.base_name}-nat"
  nat_regional_name         = "${local.base_name}-nat-regional"
  eip_name                  = "${local.base_name}-eip"
  flow_logs_name            = "${local.base_name}-flow-logs"
  vpc_flow_log_name         = "${local.base_name}-vpc-flow-log"
  vpc_flow_logs_role_name   = "${local.base_name}-vpc-flow-logs-role"
  vpc_flow_logs_policy_name = "${local.base_name}-vpc-flow-logs-policy"
  default_sg_name           = "default"

  # Nombres de route tables por tipo de subnet
  route_table_names = {
    for key, config in var.subnet_config : key => "${local.base_name}-rtb-${key}"
  }

  # Nombres de subnets
  subnet_names = {
    for item in flatten([
      for network_key, network in var.subnet_config : [
        for subnet in network.subnets : {
          key               = "${network_key}-${index(network.subnets, subnet)}"
          service           = network_key
          subnet_index      = index(network.subnets, subnet)
          cidr_block        = subnet.cidr_block
          availability_zone = subnet.availability_zone
        }
      ]
    ]) : item.key => {
      name              = "${local.base_name}-subnet-${item.service}-${item.subnet_index + 1}"
      service           = item.service
      subnet_index      = item.subnet_index
      cidr_block        = item.cidr_block
      availability_zone = item.availability_zone
    }
  }
}
