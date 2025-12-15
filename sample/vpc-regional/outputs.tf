###########################################
################# Outputs #################
###########################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = module.vpc.subnet_ids
}

output "route_table_ids" {
  description = "Map of route table IDs"
  value       = module.vpc.route_table_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (regional)"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_mode" {
  description = "NAT Gateway mode"
  value       = module.vpc.nat_gateway_mode
}

output "regional_nat_gateway_route_table_id" {
  description = "Route table ID automatically created by regional NAT Gateway"
  value       = module.vpc.regional_nat_gateway_route_table_id
}
