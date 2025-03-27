variable "dev_account_id" {
    description = "Account ID of the Dev/ACM account"
    type        = string
}

variable "domain_name" {
    description = "The base domain name"
    type        = string
}

variable "hosted_zone_id" {
    description = "The Route53 hosted zone ID"
    type        = string
}