## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "openid_thumbprints" {
  type        = list(string)
  description = "AWS IAM Provider Server Certificate Thumbprints"
  default = [
    "ffffffffffffffffffffffffffffffffffffffff"
  ]
}

variable "tags" {
  description = "AWS Resource Tag(s)"
  default     = {}
}