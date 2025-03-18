terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

resource "aws_instance" "ec2" {
  ami = "ami-032598fcc7e9d1c7a"      # ami is located specifically in a region
  instance_type = "t2.micro"
  security_groups = [aws_security_group.webtraffic.name]
}

# simple security group
resource "aws_security_group" "webtraffic" {
    name = "Allow HTTPS Basic"
    ingress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# dynamic blocks security group
variable "ingressrules" {
    type = list(number)
    default = [80,443]
}

variable "egressrules" {
    type = list(number)
    default = [80,443,25,3306,53,8080]
}

resource "aws_security_group" "webtraffic2" {
    name = "Allow HTTPS Dynamic"
    dynamic "ingress" {
        iterator = port
        for_each = var.ingressrules
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
    
    dynamic "egress" {
        iterator = port
        for_each = var.egressrules
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_eip" "elasticeip" {
  instance = aws_instance.ec2.id
}

output "EIP" {
    value = aws_eip.elasticeip.public_ip
}
