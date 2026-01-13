provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
  ami           = "ami-0a0e5d9c7acc336f1" # Ubuntu 22.04
  instance_type = "t2.micro"
  key_name      = "ci-cd-key"

  tags = {
    Name = "ci-cd-production"
  }
}
