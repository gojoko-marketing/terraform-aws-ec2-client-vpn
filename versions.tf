terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.16.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "network-services"

#  default_tags {
#    tags = module.tags.tags
#  }
}
