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

resource "aws_s3_bucket" "bucket1" {
  bucket = "eri-resume-site"
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket1.id
}


resource "aws_s3_object" "website" {
  bucket       = aws_s3_bucket.bucket1.id
  key          = "index.html"
  source       = "../static-website/index.html"
  content_type = "text/html"
  source_hash  = filemd5("../static-website/index.html")
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.bucket1.id
  index_document {
    suffix = "index.html"
  }
}

# CLOUDFRONT SETUP 

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "example-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                 = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution_oac" {
  enabled = true

  origin {
    domain_name              = aws_s3_bucket.bucket1.bucket_regional_domain_name
    origin_id                = "PrivateS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Use a built-in AWS-managed cache policy
  default_cache_behavior {
    target_origin_id       = "PrivateS3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id         = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # "Managed-CachingOptimized"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # "Managed-AllViewer"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Bucket policy that allows ONLY the CloudFront distribution (via OAC) to retrieve objects
resource "aws_s3_bucket_policy" "private_bucket_policy" {
  bucket = aws_s3_bucket.bucket1.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOriginAccessControl"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.bucket1.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution_oac.arn
          }
        }
      }
    ]
  })
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution_oac.domain_name
}