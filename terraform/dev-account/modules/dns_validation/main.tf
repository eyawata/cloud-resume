terraform {
    required_providers {
    aws = {
        source = "hashicorp/aws"
        }
    }
}

# Extract just the *.domain.com validation record
locals {
    wildcard_dvo = one([
    for dvo in var.validation_options :
        dvo if startswith(dvo.domain_name, "*.")
    ])
}

resource "aws_route53_record" "wildcard_validation" {
    provider = aws

    zone_id = var.hosted_zone_id
    name    = local.wildcard_dvo.resource_record_name
    type    = local.wildcard_dvo.resource_record_type
    ttl     = 300
    records = [local.wildcard_dvo.resource_record_value]
}

output "fqdn" {
    value = aws_route53_record.wildcard_validation.fqdn
}