output "openid_connect_provider_arn" {
  description = "AWS OpenID Connect Identity Provider ARN"
  value       = aws_iam_openid_connect_provider.this.arn
}