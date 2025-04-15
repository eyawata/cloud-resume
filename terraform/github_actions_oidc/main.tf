terraform {
    required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "5.89.0"
        }
    }
}

provider "aws" {
    region  = "ap-northeast-1"
    profile = "dev"
}

##############################################################################
# OIDC and Github Actions Setup
##############################################################################

# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
    provider = aws
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub OIDC cert thumbprint
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
    provider = aws
    name = "github-actions"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect = "Allow",
        Principal = {
            Federated = "arn:aws:iam::${var.dev_account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
            StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/master"
            }
        }
        }]
    })
}

# Attach AWS-managed policy to Role
resource "aws_iam_role_policy_attachment" "attach_github_policy" {
    provider = aws
    role       = aws_iam_role.github_actions.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
    description = "IAM Role ARN for GitHub Actions in dev account"
    value       = aws_iam_role.github_actions.arn
}