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