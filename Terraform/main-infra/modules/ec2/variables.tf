variable "ami" {}
variable "instance_type" {}
variable "key_pair_name" {}
variable "public_key_path" {}
variable "sg_id" {}
variable "subnet_id" {}
variable "env" {}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
