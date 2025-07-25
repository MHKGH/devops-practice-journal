module "vpc" {
  source                   = "../../modules/vpc"
  vpc_main_cidr_block      = var.vpc_main_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  env                      = var.env
  tags                     = var.common_tags
}

module "sg" {
  source             = "../../modules/sg"
  vpc_id             = module.vpc.vpc_id
  sg_name            = var.sg_name
  ingress_cidr_block = var.ingress_cidr_block
  env                = var.env
  tags               = var.common_tags
}

module "ec2" {
  source        = "../../modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  sg_id         = module.sg.sg_id
  subnet_id     = module.vpc.public_subnet_id
  key_pair_name   = "terraform_practice_key_pair"
  public_key_path = "~/.ssh/terraform_practice_key.pub"
  env           = var.env
  tags          = var.common_tags
}
