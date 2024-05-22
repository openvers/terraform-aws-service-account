output "assume_role" {
  description = "AWS IAM Assume Role with Web Identity Name"
  value       = aws_iam_role.this.name
}

output "assume_role_arn" {
  description = "AWS IAM Assume Role with Web Identity Name"
  value       = aws_iam_role.this.arn
}