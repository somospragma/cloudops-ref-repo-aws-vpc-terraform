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


output "route_table_details" {
  description = "Detailed information for all route tables"
  value = {
    for k, v in aws_route_table.route_table : k => {
      id   = v.id
      vpc_id = v.vpc_id
      tags = v.tags
    }
  }
}