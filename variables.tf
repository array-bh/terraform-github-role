variable "github_token" {
  type      = string
  sensitive = true
}
variable "github_owner" {
  type      = string
  sensitive = true
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Variables for dynamic values (S3 Bucket, CloudFront, AWS Account ID)
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "The CloudFront distribution ID"
  type        = string
}

variable "aws_account_id" {
  description = "Your AWS account ID"
  type        = string
}

variable "github_org" {
  description = "The GitHub organization"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository"
  type        = string
}
