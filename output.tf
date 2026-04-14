# Output the role ARN (so you can reference it in other resources if needed)
output "role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
