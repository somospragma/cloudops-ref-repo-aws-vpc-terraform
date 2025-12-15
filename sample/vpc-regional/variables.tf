###########################################
########## Common variables ###############
###########################################

variable "profile" {
  type = string
  description = "Profile name containing the access credentials to deploy the infrastructure on AWS"
}

variable "aws_region" {
  type = string
  description = "AWS region where resources will be deployed"
}

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
    description = "Project name"
}

###########################################
############ VPC variables ################
###########################################

variable "cidr_block" {
  type = string
  description = "The IPv4 CIDR block for the VPC"
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be valid CIDR"
  }
}

variable "instance_tenancy" {
  type = string
  description = "A tenancy option for instances launched into the VPC"
  default = "default"
  validation {
    condition     = can(regex("^(default|dedicated)$", var.instance_tenancy))
    error_message = "Invalid tenancy, must be default or dedicated"
  }
}

variable "enable_dns_hostnames" {
  type = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  default = true
}

variable "enable_dns_support" {
  type = bool
  description = "A boolean flag to enable/disable DNS support in the VPC"
  default = true
}

###########################################
############### IGW variables #############
###########################################

variable "create_igw" {
  type = bool
  description = "A boolean flag to enable internet gateway creation"
  default = true
}

###########################################
############### NAT variables #############
###########################################

variable "create_nat" {
  type = bool
  description = "A boolean flag to enable nat gateway creation"
  default = true
}

variable "nat_mode" {
  type = string
  description = "NAT Gateway mode: 'zonal' or 'regional'"
  default = "regional"
}

variable "nat_regional_mode" {
  type = string
  description = "Regional NAT Gateway mode: 'auto' or 'manual'"
  default = "auto"
}

###########################################
############# subnet variables ############
###########################################

variable "subnet_config" {
  type = map(object({
    custom_routes = list(object({
      destination_cidr_block    = string
      carrier_gateway_id        = optional(string)
      core_network_arn          = optional(string)
      egress_only_gateway_id    = optional(string)
      nat_gateway_id            = optional(string)
      local_gateway_id          = optional(string)
      network_interface_id      = optional(string)
      transit_gateway_id        = optional(string)
      vpc_endpoint_id           = optional(string)
      vpc_peering_connection_id = optional(string)
    }))
    public = bool
    include_nat = optional(bool, false)
    subnets = list(object({
      cidr_block        = string
      availability_zone = string
    }))
  }))
  description = "Custom subnet and route configuration"
}

###########################################
############ flow log variables ###########
###########################################

variable "flow_log_retention_in_days" {
  type = number
  validation {
    condition     = can(regex("^[0-9]*$", var.flow_log_retention_in_days))
    error_message = "Must be a number"
  }
  description = "Specifies the number of days you want to retain log events in the specified log group"
}
