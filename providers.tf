terraform {
  required_providers {
    aws = {
      configuration_aliases = [aws.project]
      source                = "hashicorp/aws"
      version               = ">=4.31.0"
    }
  }
}