variable "vpc_id" {}
variable "sg_name" {}
variable "ingress_cidr_block" {
  type        = string
  description = "CIDR allowed to access the security group."
}

variable "env" {
  type        = string
  description = "Deployment environment."
}