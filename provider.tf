terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = local.config.aws.region

  #  shared_config_files      = ["~/.aws/conf"]
  #  shared_credentials_files = ["~/.aws/creds"]
  #  profile                  = "default"
  default_tags {
    tags = {
      Environment = "Dev"
      Managed     = "Terraform"
      Owner       = "ahioros DevOps"
    }
  }
}
