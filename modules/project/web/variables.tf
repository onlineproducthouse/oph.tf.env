variable "hosted_zone_id" {
  description = "The Route53 DNS for web project"
  type        = string
  nullable    = false
}

variable "domain_name" {
  description = "The web project domain name"
  type        = string
  nullable    = false
}

variable "index_page" {
  description = "e.g. index.html"
  type        = string
  default     = "index.html"
  nullable    = false
}

variable "error_page" {
  description = "e.g. error.html"
  type        = string
  default     = "error.html"
  nullable    = false
}
