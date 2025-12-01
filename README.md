<p float="left">
  <img id="b-0" src="https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white" height="25px"/>
  <img id="b-1" src="https://img.shields.io/badge/Amazon_AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" height="25px"/>
  <img id="b-2" src="https://img.shields.io/github/actions/workflow/status/sim-parables/terraform-aws-service-account/tf-integration-test.yml?style=flat&logo=github&label=CD%20(December%202025)" height="25px"/>
</p>

# Terraform AWS Service Account

A reusable module for creating Service Accoounts with limited privileges for both Development and Production purposes.

## Usage

```hcl
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
  source  = "github.com/sim-parables/terraform-aws-service-account"

  service_account_name = var.service_account_name
  service_account_path = var.service_account_path

  providers = {
    aws.accountgen = aws.accountgen
  }
}

```

## Inputs

| Name                 | Description                             | Type         | Default | Required |
|:---------------------|:----------------------------------------|:-------------|:--------|:---------|
| service_account_name | Service Account AWS Name                | string       | N/A     | Yes      |
| service_account_path | Service Account AWS Path                | string       | N/A     | Yes      |
| roles_list           | List of Permitted Service Account Roles | list(string) | []      | No       |
| tags                 | AWS Resource Tag(s)                     | map()        | {}      | No       |

## Outputs

| Name              | Description                      |
|:------------------|:---------------------------------|
| access_id         | AWS Service Account Client ID    |
| access_token      | AWS Service Account Secret ID    |