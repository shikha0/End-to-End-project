resource "aws_instance" "kubernetes" {
  ami                         = "ami-0a7d80731ae1b2435"
  instance_type               = var.instance_type_kubernetes
  key_name                    = var.key_pair-name 
  associate_public_ip_address = true  # Changed from string "true" to boolean
  vpc_security_group_ids      = [aws_security_group.jenkins_instance.id]
  subnet_id                   = aws_subnet.public_subnet[0].id
  
  tags = {
    Name = var.tags2  # Changed 'name' to 'Name' (AWS convention)
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "cd /tmp",
      "sed -i 's/\r$//' setup.sh",
      "sh setup.sh "
    ]
  }
}
