
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      version = ">= 4.30.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "k-test"
      Owner = "luismiguelsaez"
    }
  }
}
