###############################################################################
# DNS account/Domain hosted zone owner
###############################################################################
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
    profile = "main"
}

resource "aws_iam_role" "allow_cert_dns_access" {
    name = "AllowCertDNSAccess"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Federated = "arn:aws:iam::${var.dns_account_id}:oidc-provider/token.actions.githubusercontent.com"
                },
                Action = "sts:AssumeRoleWithWebIdentity",
                Condition = {
                    StringLike = {
                        "token.actions.githubusercontent.com:sub": "repo:eyawata/cloud-resume:ref:refs/heads/master"
                    },
                    StringEquals = {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    }
                }
            },
            {
                Effect = "Allow",
                Principal = {
                    "AWS" = "arn:aws:iam::${var.dev_account_id}:root"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}
resource "aws_iam_role_policy" "cert_dns_policy" {
    name = "AllowCertDnsValidation"
    role = aws_iam_role.allow_cert_dns_access.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Effect = "Allow",
            Action = [
            "route53:ChangeResourceRecordSets",
            "route53:GetHostedZone",
            "route53:ListResourceRecordSets",
            "route53:ListHostedZones",
            "route53:GetChange"
            ],
            Resource = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
        },
        {
        Effect = "Allow",
        Action = "route53:GetChange",
        Resource = "arn:aws:route53:::change/*"
        },
        {
            Effect = "Allow",
            Action = [
            "s3:GetObject",
            "s3:GetBucketLocation",
            "s3:GetBucketPolicy",
            "s3:GetBucketPublicAccessBlock",
            "s3:PutBucketPolicy"
            ],
            Resource = "*"
        }
        ]
    })
}

data "aws_route53_zone" "zone" {
    name = var.domain_name
    private_zone = false
}