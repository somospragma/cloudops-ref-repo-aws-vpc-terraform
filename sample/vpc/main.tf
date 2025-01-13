################################################################
# Module VPC  
################################################################
module "vpc" {
  source = "../../module/vpc"
  providers = {
    aws.project = aws.alias01
  }
  client      = var.client
  project     = var.project
  environment = var.environment
  region      = var.aws_region

  cidr_block                 = var.cidr_block
  instance_tenancy           = var.instance_tenancy
  enable_dns_support         = var.enable_dns_support
  enable_dns_hostnames       = var.enable_dns_hostnames
  flow_log_retention_in_days = var.flow_log_retention_in_days

  subnet_config = var.subnet_config

  create_igw = var.create_igw
  create_nat = var.create_nat
}
