variable "dns_account_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID"
  type        = string
}