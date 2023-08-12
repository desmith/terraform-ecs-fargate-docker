terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket  = "terraform-icg"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "icgadmin"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "icgadmin"
}

