terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}

# Default profile
provider "aws" {
  alias = "default"
  region  = "ap-northeast-1"
}

# Dev account (where ACM cert is created, has to be us-east-1)
provider "aws" {
  alias   = "us_east_1_dev"
  region  = "us-east-1"
}

# DNS account (assumed role to create Route53 validation record)
provider "aws" {
  alias   = "us_east_1_dns"
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/AllowCertDNSAccess"
  }
}

###############################################################################
# Module for ACM Certificate Creation
###############################################################################

module "cert" {
  source         = "./modules/acm_certificate"

  providers = {
    aws = aws.us_east_1_dev   # account for ACM
  }
}

###############################################################################
# Module for DNS validation (assumes role and validate CNAME records)
###############################################################################


module "cert_dns" {
  source           = "./modules/dns_validation"
  hosted_zone_id   = var.hosted_zone_id
  validation_options = module.cert.validation_options

  providers = {
    aws = aws.us_east_1_dns
  }
  
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1_dev
  certificate_arn         = module.cert.certificate_arn
  validation_record_fqdns = [module.cert_dns.fqdn]
}

###############################################################################
# Module for Website and Alias Record Setup ("eriyawata.com", "www.eriyawata.com")
###############################################################################

module "website" {
  source              = "./modules/static_website"
  bucket_name         = var.bucket_name
  acm_certificate_arn = module.cert.certificate_arn
  depends_on = [
    aws_acm_certificate_validation.cert_validation
  ]

  providers = {
    aws = aws.default
  }
}

resource "aws_route53_record" "root_domain_alias" {
  provider = aws.us_east_1_dns
  zone_id  = var.hosted_zone_id
  name     = "eriyawata.com"
  type     = "A"

  alias {
    name                   = module.website.cloudfront_distribution_domain_name
    zone_id                = module.website.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_subdomain" {
  provider = aws.us_east_1_dns
  zone_id  = var.hosted_zone_id
  name     = "www.eriyawata.com"
  type     = "A"

  alias {
    name                   = module.website.cloudfront_distribution_domain_name
    zone_id                = module.website.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

###############################################################################
# OIDC and Github Actions Setup
###############################################################################

# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub OIDC cert thumbprint
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
    name = var.iam_role_name

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect = "Allow",
        Principal = {
            Federated = aws_iam_openid_connect_provider.github_oidc.arn
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

# Attach AWS-managed AdministratorAccess policy to Role
resource "aws_iam_role_policy_attachment" "attach_github_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions in dev account"
  value       = aws_iam_role.github_actions.arn
}