module "vpc" {
  source                   = "../../modules/vpc"
 
  vpc_main_cidr_block      = var.vpc_main_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  env = var.env

}

module "sg" {
  source             = "../../modules/sg"
  vpc_id             = module.vpc.vpc_id
  sg_name            = var.sg_name
  ingress_cidr_block = var.ingress_cidr_block
  env = var.env

}

module "ec2" {
  source        = "../../modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  sg_id         = module.sg.sg_id
  subnet_id     = module.vpc.public_subnet_id
  env = var.env

}
