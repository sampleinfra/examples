output "ssh_key_id" {
  value = digitalocean_ssh_key.prod.id
}

output "docker01_ip" {
  value = digitalocean_droplet.docker01.ipv4_address
}

output "tls_cert" {
  value = acme_certificate.certificate.certificate_pem
}

output "tls_key" {
  value = acme_certificate.certificate.private_key_pem 
  sensitive = true
}
