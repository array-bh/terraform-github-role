provider "aws" {
  region = "us-east-1"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
