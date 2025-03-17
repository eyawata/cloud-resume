terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}

################################################
# Default provider (ap-northeast-1)
################################################
provider "aws" {
  region  = "ap-northeast-1"
  profile = "dev"
}

################################################
# Aliased provider for us-east-1
################################################
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "dev"
}

###############################################################################
# S3 bucket
###############################################################################

resource "aws_s3_bucket" "resume-website-bucket" {
  bucket = "eri-resume-site"
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.resume-website-bucket.id
}


resource "aws_s3_object" "resume-website" {
  bucket       = aws_s3_bucket.resume-website-bucket.id
  key          = "index.html"
  source       = "../../static-website/index.html"
  content_type = "text/html"
  source_hash  = filemd5("../../static-website/index.html")
}


###############################################################################
# Cloudfront Setup
###############################################################################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "example-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                 = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution_oac" {
  enabled = true
  default_root_object = "index.html"

  aliases = [
    "eriyawata.com",
    "www.eriyawata.com"
  ]

  origin {
    domain_name              = aws_s3_bucket.resume-website-bucket.bucket_regional_domain_name
    origin_id                = "PrivateS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "PrivateS3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id         = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # "Managed-CachingOptimized"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.eriyawata_cert_validation.certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_s3_bucket_policy" "private_bucket_policy" {
  bucket = aws_s3_bucket.resume-website-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          "Service": "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.resume-website-bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution_oac.arn
          }
        }
      }
    ]
  })
}