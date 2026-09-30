# using the latest version of terraform and aws cli

terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # storing state file remotely in s3 bucket(which has already been created)

  backend "s3" {
    bucket       = "<your-s3-state-bucket>"
    key          = "path/to/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-2"
}
