#security group ek ec2 instance and remote-exec

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

output "ami" {
  value = data.aws_ami.amazon_linux.id
}

resource "aws_instance" "jenkins" {
    ami = "ami-0de716d6197524dd9"
    instance_type = var.instance_type
    key_name = var.key_pair-name 
    associate_public_ip_address = "true"
    vpc_security_group_ids = [aws_security_group.jenkins_instance.id]
    subnet_id     = aws_subnet.public_subnet[0].id
     
    tags = {
        name = var.tags
    }
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key =  file(var.private_key_path)
      host = self.public_ip
      timeout = "5m"
    }
    provisioner "remote-exec" {
      inline = [
           "echo 'connection is fine'",
           "sudo yum update -y",
           "sudo yum install java-17-amazon-corretto -y",
           "sudo java -version",
           "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
           "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
           "sudo dnf install jenkins -y",
           "sudo systemctl start jenkins",
           "sudo systemctl enable jenkins",
           "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
      ]
    }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
