/**
 * Creates all the DigitalOcean assets you need to run this example
 * 
 * 1. Run terraform `TF_VAR_domain=sampleinfra.com TF_VAR_subdomain=echo terraform apply`
 * 1. Add the generated ssh key to your keychain `ssh-add key.pem`
 * 1. Add host to your known_hosts files `ssh root@\`terraform output docker01_ip\``
 */

terraform {
  required_providers {
    acme         = "= 1.5"
    digitalocean = "= 1.14"
    tls          = "= 2.1.1"
    local        = "= 1.4"
    http         = "= 1.1.1"
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

resource "tls_private_key" "prod" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "digitalocean_ssh_key" "prod" {
  name       = "Example TLS Docker Container (TF Managed)"
  public_key = tls_private_key.prod.public_key_openssh
}

resource "local_file" "ssh_key" {
  sensitive_content = tls_private_key.prod.private_key_pem
  filename          = "${path.module}/key.pem"
  file_permission   = "0600"
}

resource "digitalocean_firewall" "web" {
  name        = "only-22-80-and-443"
  tags        = ["tf"]
  droplet_ids = [digitalocean_droplet.docker01.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["${chomp(data.http.icanhazip.body)}/24"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_droplet" "docker01" {
  image     = "docker-18-04"
  name      = "docker-01"
  region    = var.do_region
  size      = "s-1vcpu-1gb"
  ssh_keys  = [digitalocean_ssh_key.prod.id]
  tags      = ["tf"]
  user_data = <<EOF
#!/bin/bash
useradd -M echo
EOF
}

resource "digitalocean_domain" "prod" {
  name = var.domain
}

resource "digitalocean_record" "echo" {
  domain = digitalocean_domain.prod.name
  type   = "A"
  name   = var.subdomain
  value  = digitalocean_droplet.docker01.ipv4_address
}

resource "tls_private_key" "tls_cert" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.tls_cert.private_key_pem
  email_address   = var.email
}

resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = "${digitalocean_record.echo.name}.${digitalocean_domain.prod.name}"

  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.do_token
    }
  }
}

resource "digitalocean_project" "prod" {
  name        = "Example TLS Docker Container (TF Managed)"
  description = "Example TLS Docker Container (TF Managed)"
  purpose     = "Example TLS Docker Container (TF Managed)"
  environment = "Development"
  resources   = [digitalocean_domain.prod.urn, digitalocean_droplet.docker01.urn]
}
