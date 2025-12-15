###########################################
#Version definition - Terraform - Providers
###########################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.31.0"
    }
  }
}

###########################################
#Provider definition
###########################################

provider "aws" {
  region  = var.aws_region
  profile = var.profile
  alias   = "alias01"
}
