provider "aws" {
  region  = "ap-south-1"
  profile = "prasanna"
}

terraform {
  backend "s3" {
    bucket         = "terraform-practice-mhk6010"
    key            = "bootstrap/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
    dynamodb_table = "terraform-locks"


  }
}