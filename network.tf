data "aws_vpc" "redmine_vpc" {
  id =  "vpc-0e89cab00d476a1ab"
}

resource "aws_subnet" "access" {
  vpc_id     = data.aws_vpc.redmine_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = "true" 
  tags = {
    Name = "Public Subnet"
  }
}


data "aws_internet_gateway" "redmine_vpc_igw" {
  internet_gateway_id  = "igw-082ad8917ddd4c6ad"
}

resource "aws_route_table" "public_access" {
    vpc_id = data.aws_vpc.redmine_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = data.aws_internet_gateway.redmine_vpc_igw.id
    }

    tags = {
        Name = "Public Subnet Route Table."
    }
}

resource "aws_route_table_association" "public_access" {
    subnet_id = aws_subnet.access.id
    route_table_id = aws_route_table.public_access.id
}

resource "aws_security_group" "docker" {
  vpc_id =  data.aws_vpc.redmine_vpc.id

  ingress {
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "eip" {
  vpc = true
}
resource "aws_eip_association" "eip_association" {
  instance_id   = module.docker.id
  allocation_id = aws_eip.eip.id
  depends_on    = [data.aws_internet_gateway.redmine_vpc_igw]
}
