provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket       = "platform-lab-tfstate-007"
    key          = "platform-lab/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

module "lambda" {
  source = "./modules/lambda"

  name = "platform-lab-dev"
}