output "cloudfront_distribution_domain_name" {
    value = aws_cloudfront_distribution.s3_distribution_oac.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
    value = aws_cloudfront_distribution.s3_distribution_oac.hosted_zone_id
}