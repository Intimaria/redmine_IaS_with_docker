# Provisioning aws infrastructure for Redmine with terraform 

## Infrastructure
Uses Terraform with AWS. Creates a VPN with private and public subnets, 
On the public subnet, an EC2 instance provisioned
with Ansible which launches redmine & mysql instance with
docker-compose.
## Ansible 
The Redmine instance is provisioned with Ansible in /provisioning, and 
docker and docker-compose are installed using geerlingguy's galaxy roles.

## Requirements 
Needs to have created an AWS keypair with private key named 'docker.pem'.
Needs permissions to create the aforementioned resources. 


## Add value

- use cloud init to mount EBS volumes which could be used as bind volumes for redmine files & plugins
- add lifecycle policy for ebs volumes
- figure out the python ansible bugs for docker module (try running this on debian)
- if you make a RDS, instead of creating a database container, just need to add env variables to redmine container 
- Systemd el stack https://blog.container-solutions.com/running-docker-containers-with-systemd
  
## Check logs
Docker logs can be accessed by ssh'ing into the machine. First find the container names with `sudo docker ps`, then you can run `sudo docker logs <container name>`. This can make it easier to see why an ansble role may have stalled. 

## Errors 
- When provisioning, initially I had an ssh error. I thought that this was due to a dependency issue, so added a few resources to the `depends_on` list for the provisioner resource. However, this did not solve the problem. It was solved when I used `aws_eip.eip.public_ip` as the IP for the Ansible command in the provisioner resource, instead of the `module.docker.public_ip`, which is dynamically allocated.
- Another frustrating error I encountered was when I attempted to use the community.docker.docker modules  (including docker_compose), but it threw a lot of dependency errors which I just couldn't find a way around no matter what route I took. I tried adding the defualt python interpreter un the hosts file to no avail (although this did solve another error that came up due to ansible automatically detecting the python3 path & these not being the same on the host & remote). 
- Simpler error, docker requires sudo to run on EC2. 
