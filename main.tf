terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

resource "aws_key_pair" "docker" {
  key_name   = "docker"
  public_key = var.public_key
}


module "docker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "docker"
  
  ami                    = var.ami 
  instance_type          = var.class
  key_name               = aws_key_pair.docker.key_name 
  vpc_security_group_ids = [aws_security_group.docker.id]
  subnet_id              = aws_subnet.access.id
  #user_data              = "${file("user-data.yml")}"
  root_block_device = [{
    kms_key_id      = null
  }]
}



resource null_resource "provision_ec2_new" {
  depends_on = [module.docker.aws_instance, aws_eip_association.eip_association, aws_security_group.docker, aws_subnet.access ]

  provisioner "local-exec" {

      interpreter = ["/bin/bash" ,"-c"]

      command = <<EOT
                  sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
                  -u ubuntu --private-key ${var.private_key_path} \
                  -i '${aws_eip.eip.public_ip},' provisioning/redmine.yml
                  EOT 
    }
}



