/**
 * Create a docker container that uses a TLS proxy in front of it.
 * **IMPORTANT**: The ssh key for the host must be in your keychain and the host in your known_hosts otherwise the docker provider
 * will fail.
 */

terraform {
  required_providers {
    docker       = "= 2.7"
  }
}

provider "docker" {
  host = "ssh://root@${data.terraform_remote_state.provider.outputs.docker01_ip}:22"
}

data "terraform_remote_state" "provider" {
  backend = "local"

  config = {
    path = "${path.module}/../01_digitalocean_setup/terraform.tfstate"
  }
}

resource "docker_image" "echo" {
  name = "jmalloc/echo-server:latest"
}

resource "docker_container" "echo" {
  image = docker_image.echo.latest
  name  = "echo"

  user = "1000:1000"

  networks_advanced {
    name = "bridge"
  }
}

resource "docker_image" "tls_proxy" {
  name = "sampleinfra/docker-tls-proxy"
}

resource "docker_container" "tls_proxy" {
  image = docker_image.tls_proxy.latest
  name  = "tls_proxy"

  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 80
    external = 80
  }

  networks_advanced {
    name = "bridge"
  }

  env = [
    "TLS_CERTIFICATE=${data.terraform_remote_state.provider.outputs.tls_cert}",
    "TLS_KEY=${data.terraform_remote_state.provider.outputs.tls_key}",
    "UPSTREAM_HOST=${docker_container.echo.network_data[0]["ip_address"]}",
    "UPSTREAM_PORT=8080",
    "FORCE_HTTPS=true"
  ]
}

