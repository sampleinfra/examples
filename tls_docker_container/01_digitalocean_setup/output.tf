output "docker01_ip" {
  description = "IP address for docker host"
  value       = digitalocean_droplet.docker01.ipv4_address
}

output "tls_cert" {
  description = "Let's Encrypt TLS Certifcate"
  value       = acme_certificate.certificate.certificate_pem
}

output "tls_key" {
  description = "Let's Encrypt TLS Key"
  value       = acme_certificate.certificate.private_key_pem
  sensitive   = true
}
