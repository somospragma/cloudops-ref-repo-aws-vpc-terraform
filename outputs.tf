output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    for k, v in aws_subnet.subnet : k => v.id
  }
}

output "route_table_ids" {
  description = "Map of route table IDs"
  value = {
    for k, v in aws_route_table.route_table : k => v.id
  }
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (zonal or regional)"
  value       = var.create_nat ? (var.nat_mode == "regional" ? aws_nat_gateway.nat_regional[0].id : aws_nat_gateway.nat_zonal["nat-0"].id) : null
}

output "nat_gateway_mode" {
  description = "NAT Gateway mode (zonal or regional)"
  value       = var.nat_mode
}

output "regional_nat_gateway_route_table_id" {
  description = "Route table ID automatically created by regional NAT Gateway (only available in regional mode)"
  value       = var.create_nat && var.nat_mode == "regional" ? aws_nat_gateway.nat_regional[0].route_table_id : null
}