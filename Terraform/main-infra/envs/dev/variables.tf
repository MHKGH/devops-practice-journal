variable "vpc_main_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "sg_name" {}
variable "ingress_cidr_block" {}
variable "ami" {}
variable "instance_type" {}
variable "env" {}
variable "common_tags" {
  type = map(string)
  default = {
    Project     = "Practic"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "Hemanth"

  }

}