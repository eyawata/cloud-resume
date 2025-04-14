variable "bucket_name" {
  type = string
}

variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM Role for GitHub Actions"
  type = string
  default = "github-actions"
}

variable "github_org" {
  description = "GitHub Organization/User name"
  type        = string
}

variable "github_repo" {
  description = "GitHub Repository name"
  type        = string
}

variable "dev_account_id" {
  description = "Assumed Access Role for DNS validation"
  type        = string
}

variable "dns_account_id" {
  type = string
}