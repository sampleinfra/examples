variable "do_region" {
  type        = string
  description = "DigitalOcean region for droplet. See region options at https://developers.digitalocean.com/documentation/v2/#list-all-regions"
  default     = "sfo2"
}

variable "domain" {
  type        = string
  description = "Domain to use when creating DNS records and TLS certifcates"
  default     = "sampleinfra.com"
}
variable "subdomain" {
  type        = string
  description = "Subdomain to use when creating DNS records and TLS certifcates"
  default     = "echo"
}
variable "email" {
  type        = string
  description = "Email to use when creating TLS certificates"
}
variable "do_token" {
  type        = string
  description = "DigitalOcean API Token"
}
