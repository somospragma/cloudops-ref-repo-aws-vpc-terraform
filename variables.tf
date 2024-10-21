###########################################
########## Common variables ###############
###########################################
variable "client" {
  type = string
}

variable "functionality" {
  type = string
}

variable "environment" {
  type = string
}

###########################################
############ VPC variables ################
###########################################
variable "cidr_block" {
  type = string

  validation {
    # Into the validation exists two functions, the first one check something and returns true or false, and
    # the second one, evaluate if the text received is a valid CIDR, this works thanks for cidrhost function
    # cidr function calculate the number of hosts associated with a cidr block, in case of given a bad input codrhost will return an error
    # which be evaluated for "can" function, resulting in false
    # for more information about the function cidrhost, you can go to the documentation: 
    # https://developer.hashicorp.com/terraform/language/functions/cidrhost
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be valid CIDR."
  }

}

variable "instance_tenancy" {
  type    = string
  default = "default"
  validation {
    # Based on terraform documentation, instance tenancy only accepts "default" or "dedicated"
    # for that reason our validation use the can function to check if the string is default or dedicated using regex expression
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
  /*
  validation {
    condition = try(var.subnet_config.custom_routes.carrier_gateway_id, null) == null && try(core_network_arn, null) == null && try(egress_only_gateway_id, null) == null && try(nat_gateway_id, null) == null && try(vpc_endpoint_id, null) == null && try(transit_gateway_id, null) == null && try(local_gateway_id, null) == null && try(vpc_peering_connection_id, null) == null && try(network_interface_id, null) == null
    error_message = "Must include ONE of the following destinations: \n carrier_gateway_id \n core_network_arn \n egress_only_gateway_id \n nat_gateway_id \n local_gateway_id \n network_interface_id \n transit_gateway_id \n vpc_endpoint_id \n vpc_peering_connection_id"
  }
  */
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
variable "create_flow_log" {
  type    = bool
  default = false
}

variable "flow_log_retention_in_days" {
  type = number
  validation {
    condition     = can(regex("^[0-9]*$", var.flow_log_retention_in_days))
    error_message = "Must be a number"
  }
  description = "Numero dias retencion Logroup"
}