# using the version 1.15.x of terraform and v6 aws cli

terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # storing state file remotely in s3 bucket(which has already been created through GUI)

  backend "s3" {
    bucket       = "<your-s3-state-bucket>"  # specify your bucket name in which you want to store the state file
    key          = "path/to/terraform.tfstate" # specify the path to your state file
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-2"
}
