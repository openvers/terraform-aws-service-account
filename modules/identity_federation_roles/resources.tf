terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.auth_session,
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
  program = "idp"
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
## AWS IAM POLICY DOCUMENT DATA SOURCE
##
## This data source defines an OpenID Connect Provider Policy to allow OIDC federated access to
## assume a specific role and provide STS authentication. Identity Provider is configured to Github.
##
## Parameters:
## - `assume_role_policies`: List of Assume Role AWS Policy Mappings.
## ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume-role" {
  provider = aws.auth_session

  dynamic "statement" {
    for_each = var.assume_role_policies
    content {
      effect  = statement.value.effect
      actions = statement.value.actions

      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM ROLE RESOURCE
##
## This resource creates a new IAM role with assume role policies for Identity Provider configured to Github.
##
## Parameters:
## - `name`: AWS IAM role name.
## - `description`: `AWS IAM role description.
## - `max_session_duration`: Short Term Session (STS) defined duration in seconds.
## - `assume_role_policies`: List of Assume Role AWS Policy Mappings.
## - `tags`: Resource tags.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  provider = aws.auth_session

  name                 = "${var.role_name}-${local.suffix}"
  description          = var.role_description
  max_session_duration = var.max_session_duration
  assume_role_policy   = data.aws_iam_policy_document.assume-role.json
  tags                 = local.tags
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM POLICY DOCUMENT DATA SOURCE
##
## This data source defines a resouce based policy to grant specific access to a downstream role.
##
## Parameters:
## - `effect`: IAM Policy effecct.
## - `actions`: List of IAM roles.
## - `resouces`: List of AWS resources.
## ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "permissions" {
  provider = aws.auth_session

  statement {
    sid       = "PolicyDoc${replace("${var.policy_name}-${local.suffix}", "-", "")}"
    effect    = "Allow"
    actions   = var.policy_roles_list
    resources = var.policy_resources_list
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM POLICY RESOUCE
##
## This resouce creates an IAM policy with the policy contents defined in the 
## data.aws_iam_policy_document.permissions JSON document.
##
## Parameters:
## - `name`: IAM policy name.
## - `description`: IAM policy description.
## - `policy`: AWS policy JSON document defining IAM permissions.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "permissions" {
  provider = aws.auth_session

  name        = "${var.policy_name}-${local.suffix}-oidc-permissions"
  description = var.policy_description
  policy      = data.aws_iam_policy_document.permissions.json
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM ROLE POLICY ATTACHMENT RESOUCE
##
## This resouce binds the IAM policy to the STS Assume Role.
##
## Parameters:
## - `name`: IAM policy name.
## - `description`: IAM policy description.
## - `policy`: AWS policy JSON document defining IAM permissions.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  provider = aws.auth_session

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.permissions.arn
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM POLICY DOCUMENT DATA SOURCE
##
## This data source defines a resouce based policy to allow assume role to the Service Account group for the OIDC role.
## ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "group" {
  provider = aws.auth_session

  statement {
    sid    = "GroupPolicy${replace("${var.policy_name}-${local.suffix}", "-", "")}"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    resources = [aws_iam_role.this.arn]
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM POLICY RESOUCE
##
## This resouce creates an IAM policy with the policy contents defined in the 
## data.aws_iam_policy_document.group JSON document.
##
## Parameters:
## - `name`: IAM policy name.
## - `description`: IAM policy description.
## - `policy`: AWS policy JSON document defining IAM permissions.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "group" {
  provider = aws.auth_session

  name        = "${var.policy_name}-${local.suffix}-assume-role"
  description = var.policy_description
  policy      = data.aws_iam_policy_document.group.json
}


## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM POLICY RESOUCE
##
## This resouce attches an IAM policy with the policy contents defined in the 
## data.aws_iam_policy_document.group JSON document to a specific IAM group.
##
## Parameters:
## - `group`: IAM user group name.
## - `polic_arn`: IAM policy ARN.
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "this" {
  provider = aws.auth_session

  group      = var.service_account_group
  policy_arn = aws_iam_policy.group.arn
}