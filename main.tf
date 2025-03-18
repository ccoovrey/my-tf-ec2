terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "ec2" {
  ami = "ami-08b5b3a93ed654d19"      # ami is located in us-east-1 
  instance_type = "t2.micro"
}

# we are using my default vpc - so don't need allow https basic
# also no need for allow https dynamic

resource "aws_eip" "elasticeip" {
  instance = aws_instance.ec2.id
}

output "EIP" {
    value = aws_eip.elasticeip.public_ip
}
