variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "sg_id" {}
variable "subnet_id" {}
variable "env" {
  type        = string
  description = "Deployment environment (dev | test )."
}
