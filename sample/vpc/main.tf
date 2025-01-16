###########################################
############## VPC module #################
###########################################

module "vpc" {
  source = "../../module/vpc"
  providers = {
    aws.project = aws.alias01              #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  client      = var.client
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region

  # VPC configuration
  cidr_block                 = var.cidr_block
  instance_tenancy           = var.instance_tenancy
  enable_dns_support         = var.enable_dns_support
  enable_dns_hostnames       = var.enable_dns_hostnames

  # Subnet configuration
  subnet_config = var.subnet_config

  # Gateway configuration
  create_igw = var.create_igw
  create_nat = var.create_nat

  # VPC Flow Logs configuration (mandatory)
  flow_log_retention_in_days = var.flow_log_retention_in_days
}
