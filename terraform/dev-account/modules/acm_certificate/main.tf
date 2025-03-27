terraform {
    required_providers {
    aws = {
        source = "hashicorp/aws"
        }
    }
}

resource "aws_acm_certificate" "cert" {
    provider          = aws
    domain_name       = var.domain_name
    validation_method = "DNS"

    subject_alternative_names = ["*.${var.domain_name}"]
}

output "certificate_arn" {
    value = aws_acm_certificate.cert.arn
}

output "validation_options" {
    value = aws_acm_certificate.cert.domain_validation_options
}