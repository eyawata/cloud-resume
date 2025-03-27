# ###############################################################################
# # Outputs
# ###############################################################################

# output "cloudfront_distribution_domain" {
#     description = "CloudFront domain name to use in Route53 alias"
#     value       = aws_cloudfront_distribution.s3_distribution_oac.domain_name
# }

# output "cloudfront_distribution_hosted_zone_id" {
#     description = "Hosted zone ID for CloudFront alias records"
#     value       = aws_cloudfront_distribution.s3_distribution_oac.hosted_zone_id
# }

# output "certificate_arn" {
#     value = aws_acm_certificate.cert.arn
# }