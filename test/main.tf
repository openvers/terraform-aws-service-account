terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "sim-parables"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "ci-cd-aws-workspace"
    }
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS PROVIDER
##
## Configures the AWS provider with CLI Credentials.
## ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  alias   = "accountgen"
}

##---------------------------------------------------------------------------------------------------------------------
## AWS SERVICE ACCOUNT MODULE
##
## This module provisions an AWS service account along with associated roles and security groups.
##
## Parameters:
## - `service_account_name`: The display name of the new AWS Service Account.
## - `service_account_path`: The new AWS Service Account IAM Path.
## - `roles_list`: List of IAM roles to bing to new AWS Service Account.
##
## Providers:
## - `aws.accountgen`: Alias for the AWS provider for generating service accounts.
##---------------------------------------------------------------------------------------------------------------------
module "aws_service_account" {
  source = "../"

  service_account_name = var.service_account_name
  service_account_path = var.service_account_path

  providers = {
    aws.accountgen = aws.accountgen
  }
}