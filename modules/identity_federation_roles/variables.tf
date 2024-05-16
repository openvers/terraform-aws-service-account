## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "assume_role_policies" {
  description = "List of Assume Role AWS Policy Mappings"
  type = list(object({
    effect  = string,
    actions = list(string),
    conditions = list(object({
      test     = string,
      values   = list(string),
      variable = string
    })),
    principals = list(object({
      type        = string,
      identifiers = list(string)
    }))
  }))
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "role_name" {
  type        = string
  description = "AWS OIDC Role Name"
  default     = "example-oidc-role"
}

variable "role_description" {
  type        = string
  description = "AWS OIDC Role Description"
  default     = "Example OIDC STS Assume Role"
}

variable "policy_name" {
  type        = string
  description = "AWS OIDC Permissions Policy Name"
  default     = "example-oidc-permission-policy"
}

variable "policy_description" {
  type        = string
  description = "AWS OIDC Permission Policy Description"
  default     = "Example OIDC Permission Policy"
}

variable "policy_roles_list" {
  type        = list(string)
  description = "AWS IAM List of Roles to Bind to OIDC Permissions"
  default = [
    "iam:DeleteRole",
    "iam:ListInstanceProfilesForRole",
    "iam:ListAttachedRolePolicies",
    "iam:ListRolePolicies",
    "iam:GetRole",
    "iam:CreateRole",
    "iam:GetRolePolicy",
    "iam:PutRolePolicy",
    "iam:DeleteRolePolicy",
  ]
}

variable "policy_resources_list" {
  type        = list(string)
  description = "AWS IAM List of Resources to Bind to OIDC Permissions"
  default     = ["*"]
}

variable "max_session_duration" {
  type        = number
  description = "AWS OIDC STS Durations in Seconds (Between 3600 - 43200)"
  default     = 3600
}

variable "tags" {
  description = "AWS Resource Tag(s)"
  default     = {}
}
