variable "validation_options" {
    type = list(object({
    domain_name            = string
    resource_record_name   = string
    resource_record_type   = string
    resource_record_value  = string
    }))
}

variable "hosted_zone_id" {
    type = string
}