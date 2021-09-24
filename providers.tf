terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = ""    # create a bucket and add the bucket name here.
    key    = "Jenkins-tf/terraform.tfstate"
    region = "us-east-1"   
  }
}
provider "aws" {
  region = "us-east-1"
}
