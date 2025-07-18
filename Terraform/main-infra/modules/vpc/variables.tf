variable "vpc_main_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "env" {}
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}