resource "aws_acm_certificate" "eriyawata_cert" {
    provider    = aws.us_east_1
    domain_name = "eriyawata.com"
    validation_method = "DNS"

    subject_alternative_names = [
        "www.eriyawata.com"
    ]
}

output "certificate_domain_validation_options" {
    description = "Data required to create DNS validation CNAME records in the main account"
    value       = aws_acm_certificate.eriyawata_cert.domain_validation_options
}

resource "aws_acm_certificate_validation" "eriyawata_cert_validation" {
    provider        = aws.us_east_1
    certificate_arn = aws_acm_certificate.eriyawata_cert.arn

    # placeholder, filled in after main account has DNS records created
    validation_record_fqdns = []
}