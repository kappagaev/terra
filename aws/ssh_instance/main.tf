provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
    name_regex = "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"
}

resource "aws_instance" "test" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    tags = {
        Name = "test-instance"
    }
    associate_public_ip_address = true

    key_name         = "ssh-key"
}

output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.test.public_ip
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCYHd77IO/MxdTFYVd6sx8eMzfYOpaIaZCz3/ECJjNYcMp27CNpjypMU1pnefSk+478RPRsgPuA1y2Fpn+N2UY7SQhnnN4e5ve0+vSifw4ahXFd5lUGin5RiOgFWr2wa/tBaqDrJcjuXyNG68v3YXYvqXhdrJAUR5ofkipai3a448ZG2e57eg08Obk/QFeetFufIZFt9aoYkD4OWFFbEluEQuaMDE9+6Tw7AkebWyOWUtWkeA7zeAveWjn5AahL2+JzN/8IUydqW9BkBylftlYjDM7IZAmkM6WtXYsFJfIxp8Vx8vPdgWUM+E4RrdhaUv+RdA0ZuPzr682k4af8ceyVYQd6m4difctZhkMf3XiGGdAYByJ4kfvxQ3iHDgPe3NEVpEe1ngSOIA76dQaigr1LJQVPFsL5OWwuymSnFc/8Bot419VHqggkHplRBk9bYw9iMqUZBzj2JzHzqd367Oz97HtNIV1U4y6c47sEPffSyjNQkN3PPzGv5/E1rw8UaU8= vlad@kkpagaev"
}
