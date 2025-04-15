variable "domain_name" {
    description = "The base domain name"
    type        = string
}

variable "hosted_zone_id" {
    description = "The Route53 hosted zone ID"
    type        = string
}

variable "dns_account_id" {
    description = "Account ID of the zosted zone owner"
    type        = string 
}