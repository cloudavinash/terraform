terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region     = "us-west-2"
  access_key = "AKIATKZIA3FTD5QVOGGM"
  secret_key = "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"
}