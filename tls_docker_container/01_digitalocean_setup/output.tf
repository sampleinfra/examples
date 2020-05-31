output "ssh_key_id" {
  value = digitalocean_ssh_key.prod.id
}

output "docker01_ip" {
  value = digitalocean_droplet.docker01.ipv4_address
}
