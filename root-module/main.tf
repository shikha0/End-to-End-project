provider "aws" {
  region = "us-east-1"
  access_key = "##########"
  secret_key = "#############"

}
module "vpc" {
  source         = "../modules/"
  cidr           = "10.0.0.0/16"
  tenancy        = "default"
  public_subnet  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet = ["10.0.3.0/24"]
  azs_private            = ["us-east-1a"]
  azs_public =  ["us-east-1b", "us-east-1c"]
  tags = "jenkins"
  tags2 = "kubernetes"
  key_pair-name = "terraform"
  instance_type = "t2.micro"
  instance_type_kubernetes = "t3.medium"
  ports = ["22", "443", "8080"]
  private_key_path = "${path.module}/terraform.pem"
  k8s_version   = "1.28"    # Override default
  disable_swap  = "true"

}

