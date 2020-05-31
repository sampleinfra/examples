1. Run terraform `terraform apply`  
1. Add the generate ssh key to your keychain `ssh-add key.pem`  
1. Add host to your known\_hosts files `ssh root@\`terraform output docker01\_ip\

## Requirements

| Name | Version |
|------|---------|
| acme | = 1.5 |
| digitalocean | = 1.14 |
| http | = 1.1.1 |
| local | = 1.4 |
| tls | = 2.1.1 |

## Providers

| Name | Version |
|------|---------|
| acme | = 1.5 |
| digitalocean | = 1.14 |
| http | = 1.1.1 |
| local | = 1.4 |
| tls | = 2.1.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| do\_region | DigitalOcean region for droplet. See region options at https://developers.digitalocean.com/documentation/v2/#list-all-regions | `string` | `"sfo2"` | no |
| do\_token | DigitalOcean API Token | `string` | n/a | yes |
| domain | Domain to use when creating DNS records and TLS certifcates | `string` | `"sampleinfra.com"` | no |
| email | Email to use when creating TLS certificates | `string` | n/a | yes |
| subdomain | Subdomain to use when creating DNS records and TLS certifcates | `string` | `"echo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| docker01\_ip | IP address for docker host |
| tls\_cert | Let's Encrypt TLS Certifcate |
| tls\_key | Let's Encrypt TLS Key |

