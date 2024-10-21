  resource "aws_vpc" "vpc" {
    # checkov:skip=CKV2_AWS_11: In first version we won't use terraform flow logs
    cidr_block           = var.cidr_block
    instance_tenancy     = var.instance_tenancy
    enable_dns_support   = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = merge(
      { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "vpc"]))}" }
    )
  }

  resource "aws_subnet" "subnet" {
    for_each = {
      for item in flatten([for netkwork_key, network in var.subnet_config : [for subnet in network.subnets : {
        "service" : netkwork_key
        "subnet_index" : index(network.subnets, subnet)
        "cidr_block" : subnet.cidr_block
        "availability_zone" : subnet.availability_zone
      }]]) : "${item.service}-${item.subnet_index}" => item
    }
    availability_zone = each.value["availability_zone"]
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = each.value["cidr_block"]
    tags = merge(
      { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "subnet", each.value["service"], tonumber(each.value["subnet_index"]) + 1]))}" }
    )
  }


  resource "aws_route_table" "route_table" {
    for_each = var.subnet_config
    vpc_id   = aws_vpc.vpc.id
    tags = merge(
      { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "rtb", each.key]))}" }
    )
  }

  resource "aws_route_table_association" "subnet_association" {
    for_each = {
      for item in flatten([for netkwork_key, network in var.subnet_config : [for subnet in network.subnets : {
        "service" : netkwork_key
        "subnet_index" : index(network.subnets, subnet)
        "cidr_block" : subnet.cidr_block
        "availability_zone" : subnet.availability_zone
      }]]) : "${item.service}-${item.subnet_index}" => item
    }
    subnet_id      = aws_subnet.subnet["${each.value.service}-${each.value.subnet_index}"].id
    route_table_id = aws_route_table.route_table["${each.value.service}"].id
  }


  resource "aws_internet_gateway" "igw" {
    count  = var.create_igw ? 1 : 0
    vpc_id = aws_vpc.vpc.id
    tags = merge(
      { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "igw"]))}" }
    )
  }

  resource "aws_route" "internet_route" {
    for_each               = { for key, value in var.subnet_config : key => value if var.create_igw && value.public }
    route_table_id         = aws_route_table.route_table[each.key].id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw[0].id
  }

  resource "aws_route" "nat_route" {
    for_each               = { for key, value in var.subnet_config : key => value if var.create_nat && value.include_nat }
    route_table_id         = aws_route_table.route_table[each.key].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id             = aws_nat_gateway.nat["nat-0"].id
  }

  resource "aws_eip" "eip" {
    count  = var.create_nat ? 1 : 0
    # checkov:skip=CKV2_AWS_19: this elastic ip is associated with nat, for that reason the alert can be ignored
    tags = merge(
      { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "eip"]))}" }
    )
  }



  resource "aws_nat_gateway" "nat" {
    for_each = {

      for network_key, network in var.subnet_config : "nat-0" => {
        service : network_key
      } if network.public && length(network.subnets) > 0 && var.create_nat && try(network.subnets[0] != null, false)

    }

    allocation_id = aws_eip.eip[0].id
    subnet_id     = aws_subnet.subnet["${each.value.service}-0"].id

    tags = merge(
      { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "nat"]))}" }
    )

    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.igw]
  }

  resource "aws_route" "custom_route" {
    for_each = {
      for item in flatten([for netkwork_key, network in var.subnet_config : [for route in network.custom_routes : {
        "service" : netkwork_key
        "number_of_routes" : length(network.custom_routes)
        "route_index" : index(network.custom_routes, route)
        "destination_cidr_block" : route.destination_cidr_block
        "carrier_gateway_id" : route.carrier_gateway_id
        "core_network_arn"          = route.core_network_arn
        "egress_only_gateway_id"    = route.egress_only_gateway_id
        "nat_gateway_id"            = route.nat_gateway_id
        "local_gateway_id"          = route.local_gateway_id
        "network_interface_id"      = route.network_interface_id
        "transit_gateway_id"        = route.transit_gateway_id
        "vpc_endpoint_id"           = route.vpc_endpoint_id
        "vpc_peering_connection_id" = route.vpc_peering_connection_id

      }]]) : "${item.service}-route-${item.route_index}" => item if item.number_of_routes > 0
    }
    route_table_id            = aws_route_table.route_table["${each.value["service"]}"].id
    destination_cidr_block    = each.value["destination_cidr_block"]
    carrier_gateway_id        = try(each.value["carrier_gateway_id"], null)
    core_network_arn          = try(each.value["core_network_arn"], null)
    egress_only_gateway_id    = try(each.value["egress_only_gateway_id"], null)
    nat_gateway_id            = try(each.value["nat_gateway_id"], null)
    local_gateway_id          = try(each.value["local_gateway_id"], null)
    network_interface_id      = try(each.value["network_interface_id"], null)
    transit_gateway_id        = try(each.value["transit_gateway_id"], null)
    vpc_endpoint_id           = try(each.value["vpc_endpoint_id"], null)
    vpc_peering_connection_id = try(each.value["vpc_peering_connection_id"], null)
  }

  ###########################################
  ####### Resource to solve CKV2_AWS_12 #####
  ###########################################
  resource "aws_default_security_group" "default" {
    vpc_id = aws_vpc.vpc.id
  }



  ###########################################
  ####### Resource VPC Flow Logs  ###########
  ###########################################
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${join("-", tolist([var.client, var.functionality, var.environment, "vpc-flow-logs-role"]))}" #"${var.client}-${var.environment}-vpc-flow-logs-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = merge(
    { Name = "${var.client}-${var.environment}-vpc-flow-logs-role" }
  )
}

# Adjuntar la política necesaria para permitir que el rol de Flow Logs interactúe con CloudWatch
resource "aws_iam_policy" "vpc_flow_logs_policy" {
  name = "${join("-", tolist([var.client, var.functionality, var.environment, "vpc-flow-logs-policy"]))}"#"${var.client}-${var.environment}-vpc-flow-logs-policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_role_policy_attachment" {
  role       = aws_iam_role.vpc_flow_logs_role.name
  policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
}


# Crear el CloudWatch Log Group para la VPC
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/aws/vpc/flow-logs/${aws_vpc.vpc.id}"
  retention_in_days = var.flow_log_retention_in_days
  tags = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "flow-logs"]))}" }
  )
}


# Crear los Flow Logs asociados a la VPC
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id                = aws_vpc.vpc.id
  log_destination       = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  log_destination_type  = "cloud-watch-logs"
  traffic_type          = "ALL"
  iam_role_arn          = aws_iam_role.vpc_flow_logs_role.arn

  tags = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "vpc-flow-log"]))}" }
  )
}


