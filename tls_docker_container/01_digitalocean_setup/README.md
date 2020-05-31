= Setup

1. Run terraform `terraform apply`
1. Add the generate ssh key to your keychain `ssh-add key.pem`
1. Add host to your known_hosts files `ssh root@\`terraform output docker01_ip\``
