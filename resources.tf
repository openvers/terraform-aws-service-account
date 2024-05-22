/* Proxy Provider 

Defines a provider to retrieve access tokens via normal requests with IP Bound Service Account
with seperate aliases to define duties by Service Account. This provider is termed
"accountgen", and its purpose is just for generating minimum priviledged Service Accounts.
*/
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.accountgen,
      ]
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## RANDOM STRING RESOURCE
##
## This resource generates a random string of a specified length.
##
## Parameters:
## - `special`: Whether to include special characters in the random string.
## - `upper`: Whether to include uppercase letters in the random string.
## - `length`: The length of the random string.
## ---------------------------------------------------------------------------------------------------------------------
resource "random_string" "this" {
  special = false
  upper   = false
  length  = 4
}

locals {
  cloud   = "aws"
  program = "service-account"
  project = "cloud-auth"
}

locals {
  suffix = "${random_string.this.id}-${local.program}-${local.project}"

  tags = merge(var.tags, {
    program = local.program
    project = local.project
    env     = "dev"
  })
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM GROUP RESOURCE
##
## This resource defines an IAM User Group in AWS.
##
## Parameters:
## - `name`: The name of the IAM user group.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group" "this" {
  provider = aws.accountgen
  name     = "${local.suffix}-group"
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM USER RESOURCE
##
## This resource defines an IAM Service Account user in AWS.
##
## Parameters:
## - `name`: The name of the IAM user.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_user" "this" {
  provider = aws.accountgen
  name     = var.service_account_name
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM GROUP MEMBERSHIP RESOURCE
##
## This resource registers an IAM User to a IAM User Group.
##
## Parameters:
## - `name`: The name of the IAM user group membership.
## - `group`: The name of the IAM user group.
## - `users`: A list of IAM users to be assigned to the IAM user group.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group_membership" "this" {
  provider = aws.accountgen
  name     = "${local.suffix}-group-memberhip"
  group    = aws_iam_group.this.name
  users = [
    aws_iam_user.this.name
  ]
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM POLICY DOCUMENT DATA SOURCE
##
## This data source defines an IAM policy document allowing specified actions on all resources.
## https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-and-attach-iam-policy.html
##
## Parameters:
## - `sid`: A unique identifier for the policy statement.
## - `effect`: The effect of the policy (Allow or Deny).
## - `actions`: The list of actions allowed by the policy.
## - `resources`: The list of resources to which the policy applies.
## ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  provider = aws.accountgen

  statement {
    sid       = "PolicyDoc${replace(local.suffix, "-", "")}"
    effect    = "Allow"
    actions   = var.roles_list
    resources = var.resource_list
  }

  depends_on = [aws_iam_user.this]
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM GROUP POLICY RESOURCE
##
## This resource attaches an IAM policy to a specified IAM user group.
##
## Parameters:
## - `name`: The name of the IAM user policy.
## - `user`: The IAM user to which the policy is attached.
## - `policy`: The IAM policy document JSON.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group_policy" "this" {
  provider = aws.accountgen

  name   = "GroupPolicy${replace(local.suffix, "-", "")}"
  group  = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.this.json
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM ACCESS KEY RESOURCE
##
## This resource creates an access key for the dowstream infra deployment.
##
## Parameters:
## - `user`: The IAM user for whom the access key is created.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_access_key" "this" {
  provider   = aws.accountgen
  depends_on = [aws_iam_group_policy.this]

  user = aws_iam_user.this.name
}


## ---------------------------------------------------------------------------------------------------------------------
## TIME SLEEP RESOURCE
##
## This resource adds a delay to allow time for the access key to propagate.
##
## Parameters:
## - `create_duration`: The duration for which to wait before proceeding with the next steps.
## ---------------------------------------------------------------------------------------------------------------------
resource "time_sleep" "key_propagation" {
  depends_on = [aws_iam_access_key.this]

  create_duration = "60s"
}
