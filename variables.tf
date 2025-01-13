###########################################
########## Common variables ###############
###########################################
variable "client" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

###########################################
############ VPC variables ################
###########################################
variable "cidr_block" {
  type = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be valid CIDR."
  }

}

variable "instance_tenancy" {
  type    = string
  default = "default"
  validation {
    condition     = can(regex("^(default|dedicated)$", var.instance_tenancy))
    error_message = "Invalid tenancy, must be default or dedicated"
  }
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
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
}


###########################################
############### IGW variables #############
###########################################
variable "create_igw" {
  type    = bool
  default = false
}

###########################################
############### IGW variables #############
###########################################
variable "create_nat" {
  type    = bool
  default = false
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
  description = "Numero dias retencion Logroup"
}