output "access_token" {
  depends_on  = [time_sleep.key_propagation]
  description = "Authenticated Session with Service Account Key"
  value       = aws_iam_access_key.this.secret
  sensitive   = true
}

output "access_id" {
  depends_on  = [time_sleep.key_propagation]
  description = "Authenticated Session with Service Account ID"
  value       = aws_iam_access_key.this.id
  sensitive   = true
}

output "group_name" {
  description = "AWS IAM Service Account Group Name"
  value       = aws_iam_group.this.name
}

output "service_account_arn" {
  description = "AWS IAM Service Account ARN"
  value       = aws_iam_user.this.arn
}