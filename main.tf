resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubFrontendActionsRole"

  # Trust relationship for GitHub Actions OIDC authentication
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        } }
      }
    ]
  })
}

# Attach a Policy to the IAM Role
resource "aws_iam_role_policy" "github_actions_s3_cloudfront_policy" {
  name = "GitHubFrontendActionsS3CloudFrontPolicy"
  role = aws_iam_role.github_actions_role.id

  # The policy allows GitHub Actions to interact with S3 and CloudFront
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = [
          "arn:aws:cloudfront::${var.aws_account_id}:distribution/${var.cloudfront_distribution_id}"
        ]
      }
    ]
  })
}


# ----------------------------
# 5️⃣ Push GitHub Secrets
# ----------------------------

resource "github_repository_environment" "development" {
  repository  = var.github_repo
  environment = "development"
}

resource "github_actions_environment_secret" "aws_region" {
  repository      = var.github_repo
  environment     = github_repository_environment.development.environment
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}
resource "github_actions_environment_secret" "cloudfront_distribution_id" {
  repository      = var.github_repo
  environment     = github_repository_environment.development.environment
  secret_name     = "CLOUDFRONT_DISTRIBUTION_ID"
  plaintext_value = var.cloudfront_distribution_id
}
resource "github_actions_environment_secret" "s3_bucket_name" {
  repository      = var.github_repo
  environment     = github_repository_environment.development.environment
  secret_name     = "S3_BUCKET"
  plaintext_value = var.s3_bucket_name
}
resource "github_actions_environment_secret" "role_arn" {
  repository      = var.github_repo
  environment     = github_repository_environment.development.environment
  secret_name     = "ROLE_ARN"
  plaintext_value = aws_iam_role.github_actions_role.arn
}
