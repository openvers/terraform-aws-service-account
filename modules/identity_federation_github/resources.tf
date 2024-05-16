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

locals {
  cloud   = "aws"
  program = "idp"
  project = "cloud-auth"
}

locals {
  tags = merge(var.tags, {
    program = local.program
    project = local.project
    env     = "dev"
  })
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS IAM OPEN ID CONNECT PROVIDER RESOURCE
##
## This resource will create an AWS OpenID Connect Provider to allow for short-lived authorization
## without the need for Service Account credentials through Open ID Connect with trusted partners like Github.
##
## Parameters:
## - `url`: Given OpenID Connect Provider URL. Corresponds to the iss claim.
## - `client_id_list`: List of audiences to identify/authorize with provider.
## - `thumbprint_list`: list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s).
## ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "this" {
  provider = aws.auth_session

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com", ]
  thumbprint_list = var.openid_thumbprints
  tags            = local.tags
}