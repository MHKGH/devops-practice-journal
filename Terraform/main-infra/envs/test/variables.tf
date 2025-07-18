variable "env" {
  type        = string
  description = "Deployment environment identifier (e.g. dev, test)"
}
variable "vpc_main_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "sg_name" {}
variable "ingress_cidr_block" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
