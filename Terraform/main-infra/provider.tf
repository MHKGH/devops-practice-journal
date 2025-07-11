provider "aws" {
  region = "ap-south-1"

}

terraform {
  backend "s3" {
    bucket = "terraform-practice-mhk6010"
    key = "dev/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true

    use_lockfile = true
    lock_table = "terraform-state-lock"
    
  }
}