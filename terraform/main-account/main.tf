###############################################################################
# main-account-providers.tf
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



###############################################################################
# route53-alias.tf
###############################################################################
# You pass in the distribution domain name and domain zone ID from the test account's 
# output (via pipeline variable).
data "aws_route53_zone" "eriyawata_zone" {
    name         = "eriyawata.com."
    private_zone = false
}

variable "cloudfront_domain_name" {
    type = string
}

variable "cloudfront_hosted_zone_id" {
    type    = string
}

# For apex domain: eriyawata.com
resource "aws_route53_record" "apex_alias" {
    zone_id = data.aws_route53_zone.eriyawata_zone.zone_id
    name    = "eriyawata.com"
    type    = "A"

    alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
    }
}

# For subdomain: www.eriyawata.com
resource "aws_route53_record" "www_alias" {
    zone_id = data.aws_route53_zone.eriyawata_zone.zone_id
    name    = "www.eriyawata.com"
    type    = "A"

    alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
    }
}
